"""
N3XUS COS AI Routing
Routes AI requests to appropriate services
"""

from typing import Dict, Any

# AI Service routing configuration
AI_SERVICES = {
    'puabo_api_ai_hf': {
        'name': 'PUABO API/AI-HF Hybrid',
        'url': 'http://localhost:3401',
        'capabilities': [
            'text-generation',
            'text-classification',
            'question-answering',
            'summarization',
            'translation'
        ],
        'enabled': True
    }
}


def route_ai_request(task_type: str) -> Dict[str, Any]:
    """
    Route AI request to appropriate service based on task type
    
    Args:
        task_type: Type of AI task (e.g., 'text-generation', 'summarization')
        
    Returns:
        Service configuration for handling the request
    """
    for service_id, service_config in AI_SERVICES.items():
        if service_config['enabled'] and task_type in service_config['capabilities']:
            return {
                'service': service_id,
                'url': service_config['url'],
                'name': service_config['name']
            }
    
    return {
        'error': f'No service available for task type: {task_type}'
    }


def get_active_ai_services() -> Dict[str, Any]:
    """Get list of active AI services"""
    return {
        service_id: config
        for service_id, config in AI_SERVICES.items()
        if config['enabled']
    }
