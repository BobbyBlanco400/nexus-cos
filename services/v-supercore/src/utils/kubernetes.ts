import * as k8s from '@kubernetes/client-node';

let k8sClient: {
  coreApi: k8s.CoreV1Api;
  appsApi: k8s.AppsV1Api;
  autoscalingApi: k8s.AutoscalingV2Api;
} | null = null;

export async function initKubernetes() {
  if (k8sClient) {
    return k8sClient;
  }
  
  const kc = new k8s.KubeConfig();
  
  if (process.env.KUBERNETES_SERVICE_HOST) {
    // Running inside Kubernetes cluster
    kc.loadFromCluster();
  } else {
    // Running outside cluster (development)
    kc.loadFromDefault();
  }
  
  k8sClient = {
    coreApi: kc.makeApiClient(k8s.CoreV1Api),
    appsApi: kc.makeApiClient(k8s.AppsV1Api),
    autoscalingApi: kc.makeApiClient(k8s.AutoscalingV2Api)
  };
  
  console.log('✅ Kubernetes client initialized');
  
  return k8sClient;
}

export function getKubernetes() {
  if (!k8sClient) {
    throw new Error('Kubernetes not initialized. Call initKubernetes() first.');
  }
  return k8sClient;
}
