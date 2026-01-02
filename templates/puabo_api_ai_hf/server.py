#!/usr/bin/env python3
"""
PUABO API/AI-HF Hybrid Service
Main server entry point with HuggingFace Inference API integration
"""

import os
import sys
import json
import logging
from datetime import datetime, timezone
from flask import Flask, jsonify, request
from werkzeug.exceptions import HTTPException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# Service configuration
SERVICE_NAME = "puabo_api_ai_hf"
SERVICE_VERSION = "1.0.0"
PORT = int(os.environ.get('PORT', 3401))

# HuggingFace configuration
HF_API_TOKEN = os.environ.get('HUGGINGFACE_API_TOKEN', '')
HF_INFERENCE_ENDPOINT = os.environ.get('HF_INFERENCE_ENDPOINT', 'https://api-inference.huggingface.co/models/')

# Service start time
START_TIME = datetime.now(timezone.utc)


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    uptime = (datetime.now(timezone.utc) - START_TIME).total_seconds()
    return jsonify({
        'status': 'ok',
        'service': SERVICE_NAME,
        'version': SERVICE_VERSION,
        'port': PORT,
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'uptime_seconds': uptime,
        'huggingface_configured': bool(HF_API_TOKEN)
    }), 200


@app.route('/status', methods=['GET'])
def status():
    """Detailed status endpoint"""
    uptime = (datetime.now(timezone.utc) - START_TIME).total_seconds()
    return jsonify({
        'service': SERVICE_NAME,
        'version': SERVICE_VERSION,
        'status': 'running',
        'uptime_seconds': uptime,
        'port': PORT,
        'endpoints': [
            '/health',
            '/status',
            '/api/v1/inference',
            '/api/v1/models'
        ],
        'capabilities': [
            'text-generation',
            'text-classification',
            'question-answering',
            'summarization',
            'translation'
        ]
    }), 200


@app.route('/', methods=['GET'])
def root():
    """Root endpoint with service information"""
    return jsonify({
        'message': f'{SERVICE_NAME} is running',
        'version': SERVICE_VERSION,
        'documentation': '/status',
        'health': '/health'
    }), 200


@app.route('/api/v1/inference', methods=['POST'])
def inference():
    """
    HuggingFace inference endpoint
    Accepts: { "model": "model-name", "inputs": "text", "parameters": {} }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        model = data.get('model')
        inputs = data.get('inputs')
        
        if not model or not inputs:
            return jsonify({'error': 'Missing required fields: model and inputs'}), 400
        
        # For now, return a mock response
        # In production, this would call HuggingFace API
        logger.info(f"Inference request for model: {model}")
        
        return jsonify({
            'status': 'success',
            'model': model,
            'result': {
                'generated_text': f'[Mock inference result for: {inputs[:50]}...]',
                'confidence': 0.95
            },
            'timestamp': datetime.now(timezone.utc).isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Inference error: {str(e)}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/v1/models', methods=['GET'])
def list_models():
    """List available HuggingFace models"""
    models = [
        {
            'name': 'gpt2',
            'task': 'text-generation',
            'status': 'available'
        },
        {
            'name': 'distilbert-base-uncased-finetuned-sst-2-english',
            'task': 'text-classification',
            'status': 'available'
        },
        {
            'name': 'facebook/bart-large-cnn',
            'task': 'summarization',
            'status': 'available'
        }
    ]
    
    return jsonify({
        'models': models,
        'count': len(models),
        'timestamp': datetime.now(timezone.utc).isoformat()
    }), 200


@app.errorhandler(HTTPException)
def handle_http_exception(e):
    """Handle HTTP exceptions"""
    return jsonify({
        'error': e.description,
        'status_code': e.code
    }), e.code


@app.errorhandler(Exception)
def handle_exception(e):
    """Handle general exceptions"""
    logger.error(f"Unhandled exception: {str(e)}")
    return jsonify({
        'error': 'Internal server error',
        'message': str(e)
    }), 500


def main():
    """Main entry point"""
    logger.info(f"Starting {SERVICE_NAME} v{SERVICE_VERSION}")
    logger.info(f"Port: {PORT}")
    logger.info(f"HuggingFace configured: {bool(HF_API_TOKEN)}")
    
    try:
        app.run(
            host='0.0.0.0',
            port=PORT,
            debug=False,
            threaded=True
        )
    except Exception as e:
        logger.error(f"Failed to start server: {str(e)}")
        sys.exit(1)


if __name__ == '__main__':
    main()
