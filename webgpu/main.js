const canvas = document.getElementById('gpu-canvas');

async function init() {
  if (!navigator.gpu) {
    console.error('WebGPU not supported');
    return;
  }

  const adapter = await navigator.gpu.requestAdapter();
  const device = await adapter.requestDevice();

  const context = canvas.getContext('webgpu');
  const format = navigator.gpu.getPreferredCanvasFormat();

  context.configure({
    device,
    format,
    alphaMode: 'premultiplied'
  });

  const vertices = new Float32Array([
    // position   // uv
    -1, -1,      0, 0,
     1, -1,      1, 0,
    -1,  1,      0, 1,
     1,  1,      1, 1
  ]);

  const vertexBuffer = device.createBuffer({
    size: vertices.byteLength,
    usage: GPUBufferUsage.VERTEX,
    mappedAtCreation: true
  });
  new Float32Array(vertexBuffer.getMappedRange()).set(vertices);
  vertexBuffer.unmap();

  const vertexBufferLayout = {
    arrayStride: 4 * 4,
    attributes: [
      { shaderLocation: 0, offset: 0, format: 'float32x2' },
      { shaderLocation: 1, offset: 8, format: 'float32x2' }
    ]
  };

  const shaderModule = device.createShaderModule({
    code: `
      struct VSOut {
        @builtin(position) Position : vec4<f32>,
        @location(0) uv : vec2<f32>,
      };

      @vertex
      fn vs_main(
        @location(0) position: vec2<f32>,
        @location(1) uv: vec2<f32>
      ) -> VSOut {
        var out: VSOut;
        out.Position = vec4<f32>(position, 0.0, 1.0);
        out.uv = uv;
        return out;
      }

      @group(0) @binding(0)
      var<uniform> uTime : f32;

      fn hash(p: vec2<f32>) -> f32 {
        var q = fract(p * vec2<f32>(123.34, 456.21));
        q = q + dot(q, q + 45.32);
        return fract(q.x * q.y);
      }

      @fragment
      fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
        let uv = in.uv;
        let left = vec3<f32>(0.0, 0.94, 1.0);
        let right = vec3<f32>(0.48, 0.0, 1.0);
        var baseColor = mix(left, right, uv.x);

        let pulse = 0.5 + 0.5 * sin(uTime * 0.8);
        let n = hash(uv * 500.0 + uTime * 5.0);
        let flicker = mix(0.9, 1.1, n);

        let centerDist = length(uv - vec2<f32>(0.5, 0.5));
        let rim = smoothstep(0.6, 0.2, centerDist);

        var color = baseColor;
        color *= pulse * flicker;
        color += vec3<f32>(0.0, 1.0, 1.0) * rim * 0.25;

        return vec4<f32>(color, 0.95);
      }
    `
  });

  const uniformBuffer = device.createBuffer({
    size: 4,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
  });

  const bindGroupLayout = device.createBindGroupLayout({
    entries: [
      {
        binding: 0,
        visibility: GPUShaderStage.FRAGMENT,
        buffer: { type: 'uniform' }
      }
    ]
  });

  const bindGroup = device.createBindGroup({
    layout: bindGroupLayout,
    entries: [
      {
        binding: 0,
        resource: { buffer: uniformBuffer }
      }
    ]
  });

  const pipeline = device.createRenderPipeline({
    layout: device.createPipelineLayout({
      bindGroupLayouts: [bindGroupLayout]
    }),
    vertex: {
      module: shaderModule,
      entryPoint: 'vs_main',
      buffers: [vertexBufferLayout]
    },
    fragment: {
      module: shaderModule,
      entryPoint: 'fs_main',
      targets: [
        {
          format
        }
      ]
    },
    primitive: {
      topology: 'triangle-strip',
      stripIndexFormat: 'uint32'
    }
  });

  function frame(timeMs) {
    const time = timeMs / 1000;
    device.queue.writeBuffer(uniformBuffer, 0, new Float32Array([time]));

    const encoder = device.createCommandEncoder();
    const textureView = context.getCurrentTexture().createView();

    const pass = encoder.beginRenderPass({
      colorAttachments: [
        {
          view: textureView,
          clearValue: { r: 0.01, g: 0.01, b: 0.05, a: 1.0 },
          loadOp: 'clear',
          storeOp: 'store'
        }
      ]
    });

    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.setVertexBuffer(0, vertexBuffer);
    pass.draw(4, 1, 0, 0);
    pass.end();

    device.queue.submit([encoder.finish()]);

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);
}

init();
