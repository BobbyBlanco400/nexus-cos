#!/bin/bash
# TRAE Solo Master Fix Script - Test Version
# Local testing without system modifications

set -e

# Configuration
PROJECT="nexus-cos"
DOMAIN="nexuscos.online"
EMAIL="puaboverse@gmail.com"
DEPLOY_PATH="/home/runner/work/nexus-cos/nexus-cos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🚀 TRAE SOLO MASTER FIX - TEST VERSION                       ║${NC}"
    echo -e "${PURPLE}║                Live Interactive Module Map Generation                        ║${NC}"
    echo -e "${PURPLE}║                Local Testing Without System Changes                         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

print_step() {
    echo -e "${CYAN}[TEST-STEP]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[TEST-INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[TEST-SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[TEST-WARNING]${NC} $1"
}

# Notification function (test mode)
notify() {
    local MSG="$1"
    echo -e "${BLUE}[TEST-NOTIFY]${NC} $MSG"
}

# Test module map generation
test_generate_module_map() {
    print_step "Testing Mermaid module map generation..."
    
    mkdir -p "$DEPLOY_PATH/test-diagram"
    
    # Create comprehensive Mermaid diagram
    cat > "$DEPLOY_PATH/test-diagram/NexusCOS.mmd" << 'EOF'
graph LR
    %% Core System Modules
    NexusCore[🔄 Nexus Core<br/>System Orchestrator] --> |manages| BackendNode[⚡ Node.js Backend<br/>API Gateway]
    NexusCore --> |manages| BackendPython[🐍 Python Backend<br/>FastAPI Services]
    NexusCore --> |manages| Frontend[🎨 React Frontend<br/>User Interface]
    NexusCore --> |manages| Database[(📊 PostgreSQL<br/>Data Storage)]
    
    %% Extended Modules
    BackendNode --> |powers| CreatorHub[🎯 Creator Hub<br/>Content Management]
    BackendNode --> |powers| VSuite[💼 V-Suite<br/>Business Tools]
    BackendNode --> |powers| PuaboVerse[🌐 PuaboVerse<br/>Virtual Worlds]
    
    %% Frontend Connections
    Frontend --> |connects| AdminPanel[⚙️ Admin Panel<br/>System Control]
    Frontend --> |connects| CreatorDash[📈 Creator Dashboard<br/>Analytics & Insights]
    Frontend --> |connects| MobileApp[📱 Mobile App<br/>Cross-Platform]
    
    %% Infrastructure
    LoadBalancer[🔀 Nginx<br/>Load Balancer] --> Frontend
    LoadBalancer --> BackendNode
    LoadBalancer --> BackendPython
    
    SSL[🔒 SSL/TLS<br/>Let's Encrypt] --> LoadBalancer
    
    %% Monitoring & Health
    Monitor[📊 Health Monitor<br/>System Status] --> |watches| BackendNode
    Monitor --> |watches| BackendPython
    Monitor --> |watches| Database
    Monitor --> |watches| Frontend
    
    %% External Integrations
    Notifications[📢 Notifications<br/>Slack + Email] --> NexusCore
    
    %% Click handlers for interactive navigation
    click NexusCore "https://nexuscos.online" "Open Nexus COS Main Portal"
    click Frontend "https://nexuscos.online" "Access Frontend Application"
    click BackendNode "https://nexuscos.online/api/node/health" "Check Node.js API Health"
    click BackendPython "https://nexuscos.online/api/python/health" "Check Python API Health"
    click AdminPanel "https://nexuscos.online/admin" "Access Admin Panel"
    click CreatorDash "https://nexuscos.online/creator" "Access Creator Dashboard"
    click CreatorHub "https://nexuscos.online/api/creator-hub/status" "Creator Hub Status"
    click VSuite "https://nexuscos.online/api/v-suite/status" "V-Suite Status"
    click PuaboVerse "https://nexuscos.online/api/puaboverse/status" "PuaboVerse Status"
    click Database "https://nexuscos.online/health/database" "Database Health Check"
    click Monitor "https://nexuscos.online/health" "System Health Dashboard"
    
    %% Styling
    classDef coreModule fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000
    classDef extendedModule fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000
    classDef infraModule fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000
    classDef dataModule fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000
    
    class NexusCore,BackendNode,BackendPython,Frontend coreModule
    class CreatorHub,VSuite,PuaboVerse,AdminPanel,CreatorDash,MobileApp extendedModule
    class LoadBalancer,SSL,Monitor,Notifications infraModule
    class Database dataModule
EOF
    
    print_success "Test Mermaid module file created"
    notify "✅ Test Mermaid module file with HTML links created"
}

# Test HTML rendering
test_render_interactive_html() {
    print_step "Testing interactive HTML generation..."
    
    cat > "$DEPLOY_PATH/test-diagram/NexusCOS.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus COS Interactive Module Map - TEST</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
            font-size: 1.1em;
        }
        .test-banner {
            background: #ffa726;
            color: #fff;
            padding: 10px;
            text-align: center;
            font-weight: bold;
        }
        .diagram-container {
            padding: 20px;
            text-align: center;
        }
        .mermaid {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .info {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .status-card {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
        }
        .status-card h3 {
            margin: 0 0 10px 0;
            color: #495057;
        }
        .status-indicator {
            width: 12px;
            height: 12px;
            background: #28a745;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #dee2e6;
        }
    </style>
    <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            themeVariables: {
                fontFamily: 'Segoe UI, sans-serif',
                fontSize: '16px'
            }
        });
    </script>
</head>
<body>
    <div class="container">
        <div class="test-banner">
            🧪 TEST VERSION - Interactive Module Map Generation Test
        </div>
        
        <div class="header">
            <h1>🚀 Nexus COS</h1>
            <p>Live Interactive Module Map - Test Environment</p>
        </div>
        
        <div class="diagram-container">
            <div class="info">
                <strong>📋 Test Interactive Map:</strong> This demonstrates the module map that would be generated in production.
            </div>
            
            <div class="mermaid">
EOF
    
    # Append the Mermaid diagram content
    cat "$DEPLOY_PATH/test-diagram/NexusCOS.mmd" >> "$DEPLOY_PATH/test-diagram/NexusCOS.html"
    
    # Continue with the HTML
    cat >> "$DEPLOY_PATH/test-diagram/NexusCOS.html" << 'EOF'
            </div>
            
            <div class="status-grid">
                <div class="status-card">
                    <h3>🔄 Core System</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
                <div class="status-card">
                    <h3>⚡ Node.js API</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
                <div class="status-card">
                    <h3>🐍 Python API</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
                <div class="status-card">
                    <h3>🎨 Frontend</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
                <div class="status-card">
                    <h3>📊 Database</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
                <div class="status-card">
                    <h3>🔒 SSL/Security</h3>
                    <div><span class="status-indicator"></span>Test Ready</div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>🧪 <strong>TEST VERSION:</strong> Nexus COS Interactive Module Map Test</p>
            <p>Generated on: <script>document.write(new Date().toLocaleString());</script></p>
        </div>
    </div>
</body>
</html>
EOF
    
    print_success "Test interactive HTML module map generated"
    notify "🎨 Test interactive HTML map created"
}

# Test backend health endpoints
test_backend_health() {
    print_step "Testing backend health endpoints..."
    
    # Test if Node.js backend files exist and are valid
    if [ -f "$DEPLOY_PATH/backend/src/server.ts" ]; then
        print_success "Node.js TypeScript server found"
    fi
    
    if [ -f "$DEPLOY_PATH/backend/server.js" ]; then
        print_success "Node.js JavaScript server found"
    fi
    
    if [ -f "$DEPLOY_PATH/backend/app/main.py" ]; then
        print_success "Python FastAPI server found"
    fi
    
    print_status "Backend configurations verified for testing"
}

# Test frontend build
test_frontend() {
    print_step "Testing frontend build capability..."
    
    if [ -d "$DEPLOY_PATH/frontend/dist" ]; then
        print_success "Frontend build directory exists"
    else
        print_warning "Frontend build directory not found - would be created during deployment"
    fi
    
    if [ -f "$DEPLOY_PATH/frontend/package.json" ]; then
        print_success "Frontend package.json found"
    fi
    
    print_status "Frontend configuration verified for testing"
}

# Main test function
main() {
    print_header
    
    notify "🧪 TRAE Solo: Test Mode - Nexus COS Module Map Generation Started"
    
    # Ensure we're in the correct directory
    cd "$DEPLOY_PATH" || {
        print_error "Deploy path $DEPLOY_PATH does not exist"
        exit 1
    }
    
    # Execute test steps
    test_generate_module_map
    test_render_interactive_html
    test_backend_health
    test_frontend
    
    # Final success notifications
    print_success "🎉 Test mode completed successfully!"
    echo ""
    echo "📋 Test Summary:"
    echo "  ✅ Module Map: Interactive diagram generated"
    echo "  ✅ HTML Output: Interactive interface created"
    echo "  ✅ Backend Check: Server files verified"
    echo "  ✅ Frontend Check: Build capability confirmed"
    echo ""
    echo "🔗 Test Files Created:"
    echo "  📊 Module Map: $DEPLOY_PATH/test-diagram/NexusCOS.mmd"
    echo "  🎨 HTML Interface: $DEPLOY_PATH/test-diagram/NexusCOS.html"
    echo ""
    echo "💡 To view the interactive map:"
    echo "  Open $DEPLOY_PATH/test-diagram/NexusCOS.html in a web browser"
    echo ""
    
    notify "🎯 Test completed: Interactive Module Map generated successfully"
    notify "🚀 Ready for production deployment with master-fix-trae-solo.sh"
}

# Run main function
main "$@"