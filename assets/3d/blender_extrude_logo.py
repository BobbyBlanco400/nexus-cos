import bpy
import os

# Adjust this path as needed
svg_path = bpy.path.abspath("//../svg/logo.svg")

# Clear scene (optional)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Import SVG
bpy.ops.import_curve.svg(filepath=svg_path)

# All imported curves are selected
for obj in bpy.context.selected_objects:
    if obj.type == 'CURVE':
        # Set some curve properties
        obj.data.fill_mode = 'BOTH'
        obj.data.extrude = 0.1  # depth
        obj.data.bevel_depth = 0.01
        obj.data.bevel_resolution = 2

# Convert curves to mesh
bpy.ops.object.convert(target='MESH')

# Join all logo meshes into single object
bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        obj.select_set(True)
bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
bpy.ops.object.join()

logo_obj = bpy.context.active_object
logo_obj.name = "N3XUS_vCOS_Logo"

# Optional: center and scale
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
logo_obj.location = (0, 0, 0)
logo_obj.scale = (1, 1, 1)

# Export as GLB and OBJ
export_dir = bpy.path.abspath("//")
glb_path = os.path.join(export_dir, "logo.glb")
obj_path = os.path.join(export_dir, "logo.obj")

bpy.ops.export_scene.gltf(
    filepath=glb_path,
    export_selected=True,
    export_yup=True,
    export_apply=True
)

bpy.ops.export_scene.obj(
    filepath=obj_path,
    use_selection=True
)

print("Exported logo to:", glb_path, "and", obj_path)
