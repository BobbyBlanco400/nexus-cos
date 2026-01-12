using UnityEngine;

/// <summary>
/// Pulse controller for HoloCore_N3XUS holographic material
/// Drives the _EmissionStrength parameter with customizable pulse patterns
/// </summary>
public class Pulse : MonoBehaviour
{
    [Header("Holographic Material")]
    [Tooltip("Material using HoloCore_N3XUS shader")]
    public Material holoMaterial;
    
    [Header("Pulse Settings")]
    [Tooltip("Base emission strength")]
    [Range(0f, 5f)]
    public float baseEmission = 1.0f;
    
    [Tooltip("Pulse amplitude")]
    [Range(0f, 3f)]
    public float pulseAmplitude = 0.5f;
    
    [Tooltip("Pulse frequency (Hz)")]
    [Range(0.1f, 5f)]
    public float pulseFrequency = 0.8f;
    
    [Header("Advanced")]
    [Tooltip("Enable secondary harmonic")]
    public bool enableHarmonic = false;
    
    [Tooltip("Harmonic frequency multiplier")]
    [Range(1f, 4f)]
    public float harmonicMultiplier = 2.0f;
    
    [Tooltip("Harmonic amplitude")]
    [Range(0f, 1f)]
    public float harmonicAmplitude = 0.2f;
    
    private float time = 0f;
    
    void Start()
    {
        if (holoMaterial == null)
        {
            // Try to get material from renderer
            Renderer renderer = GetComponent<Renderer>();
            if (renderer != null)
            {
                holoMaterial = renderer.material;
            }
        }
        
        if (holoMaterial == null)
        {
            Debug.LogError("Pulse: No holographic material assigned!");
            enabled = false;
        }
    }
    
    void Update()
    {
        if (holoMaterial == null) return;
        
        time += Time.deltaTime;
        
        // Primary pulse wave
        float pulse = Mathf.Sin(time * pulseFrequency * 2f * Mathf.PI);
        
        // Add harmonic if enabled
        if (enableHarmonic)
        {
            float harmonic = Mathf.Sin(time * pulseFrequency * harmonicMultiplier * 2f * Mathf.PI);
            pulse += harmonic * harmonicAmplitude;
        }
        
        // Calculate final emission strength
        float emission = baseEmission + (pulse * pulseAmplitude);
        emission = Mathf.Max(0f, emission); // Ensure non-negative
        
        // Update shader parameter
        holoMaterial.SetFloat("_EmissionStrength", emission);
    }
    
    /// <summary>
    /// Trigger a one-time emission spike
    /// </summary>
    public void TriggerSpike(float spikeIntensity = 2f, float duration = 0.3f)
    {
        StartCoroutine(SpikeCoroutine(spikeIntensity, duration));
    }
    
    private System.Collections.IEnumerator SpikeCoroutine(float intensity, float duration)
    {
        float elapsed = 0f;
        float originalBase = baseEmission;
        
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            
            // Spike up then back down
            float curve = Mathf.Sin(t * Mathf.PI);
            baseEmission = originalBase + (intensity * curve);
            
            yield return null;
        }
        
        baseEmission = originalBase;
    }
}
