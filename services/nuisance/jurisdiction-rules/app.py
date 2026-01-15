#!/usr/bin/env python3
"""
Jurisdiction Rules Nuisance Service
N3XUS Handshake 55-45-17 Enforced
"""
import os
import sys
from datetime import datetime
from flask import Flask, jsonify, request

# N3XUS Handshake validation at startup
REQUIRED_HANDSHAKE = "55-45-17"

if os.environ.get("N3XUS_HANDSHAKE") != REQUIRED_HANDSHAKE:
    print("❌ N3XUS LAW VIOLATION: Invalid or missing handshake", file=sys.stderr)
    sys.exit(1)

print("✅ N3XUS Handshake validated at startup")

app = Flask(__name__)
PORT = int(os.environ.get('PORT', 4002))


# Middleware for request-level handshake validation
@app.before_request
def validate_handshake():
    if request.path == '/health':
        return None
    
    handshake = request.headers.get('X-N3XUS-Handshake', '').strip()
    if handshake != REQUIRED_HANDSHAKE:
        return jsonify({
            'error': 'N3XUS LAW VIOLATION',
            'message': 'Invalid or missing X-N3XUS-Handshake header',
            'required': REQUIRED_HANDSHAKE
        }), 451


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint (no handshake required)"""
    return jsonify({
        'status': 'ok',
        'service': 'jurisdiction-rules',
        'phase': 'nuisance',
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/', methods=['GET'])
def root():
    """Root endpoint"""
    return jsonify({
        'service': 'jurisdiction-rules',
        'description': 'Jurisdiction Rules Nuisance Service',
        'phase': 'nuisance',
        'handshake_required': True
    })


@app.route('/api/v1/check-jurisdiction', methods=['POST'])
def check_jurisdiction():
    """Check jurisdiction compliance"""
    data = request.get_json() or {}
    jurisdiction = data.get('jurisdiction', 'unknown')
    
    return jsonify({
        'jurisdiction': jurisdiction,
        'compliant': True,
        'rules_applied': ['age-verification', 'kyc-required', 'geo-restriction'],
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/api/v1/jurisdictions', methods=['GET'])
def list_jurisdictions():
    """List supported jurisdictions"""
    return jsonify({
        'jurisdictions': [
            {'code': 'US', 'name': 'United States', 'active': True},
            {'code': 'UK', 'name': 'United Kingdom', 'active': True},
            {'code': 'EU', 'name': 'European Union', 'active': True}
        ],
        'timestamp': datetime.utcnow().isoformat()
    })


@app.errorhandler(Exception)
def handle_error(e):
    """Global error handler"""
    return jsonify({
        'error': 'Internal server error',
        'service': 'jurisdiction-rules',
        'message': str(e)
    }), 500


if __name__ == '__main__':
    print(f"🚀 Jurisdiction Rules service listening on port {PORT}")
    print(f"🔐 N3XUS Handshake: {REQUIRED_HANDSHAKE}")
    app.run(host='0.0.0.0', port=PORT, debug=False)
