#!/usr/bin/env node
/**
 * GitHub Copilot Master Prompt Script - Nexus COS PF v1.2
 * 
 * This script generates scaffolding for the complete Nexus COS ecosystem
 * based on the Project Framework v1.2 with dependency mapping.
 * 
 * Usage: node copilot-master-scaffold.js [options]
 * 
 * Features:
 * - Scaffolds services/ and modules/ directory structure
 * - Creates boilerplate service-to-service API calls based on deps.yaml
 * - Builds Docker Compose configs per module/service
 * - Generates API documentation and OpenAPI specs
 * - Creates test templates with dependency mocking
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

class NexusCOSScaffolder {
    constructor() {
        this.rootDir = process.cwd();
        this.servicesDir = path.join(this.rootDir, 'services');
        this.modulesDir = path.join(this.rootDir, 'modules');
        this.outputDir = path.join(this.rootDir, 'generated');
        
        // Service/Module definitions based on PF v1.2
        this.serviceDefinitions = this.loadServiceDefinitions();
        this.moduleDefinitions = this.loadModuleDefinitions();
    }

    /**
     * Main scaffolding function - GitHub Copilot will use this
     */
    async scaffold() {
        console.log('🚀 Starting Nexus COS PF v1.2 Scaffolding...');
        
        // Create base directory structure
        await this.createBaseStructure();
        
        // Scaffold core services
        await this.scaffoldCoreServices();
        
        // Scaffold business modules
        await this.scaffoldBusinessModules();
        
        // Generate service-to-service communication
        await this.generateServiceCommunication();
        
        // Create Docker configurations
        await this.generateDockerConfigs();
        
        // Generate API documentation
        await this.generateAPIDocumentation();
        
        // Create deployment scripts
        await this.generateDeploymentScripts();
        
        console.log('✅ Nexus COS PF v1.2 Scaffolding Complete!');
        console.log(`📁 Generated files in: ${this.outputDir}`);
    }

    /**
     * Load service definitions from deps.yaml files
     */
    loadServiceDefinitions() {
        const services = {};
        const servicesPath = this.servicesDir;
        
        if (fs.existsSync(servicesPath)) {
            const serviceDirs = fs.readdirSync(servicesPath, { withFileTypes: true })
                .filter(dirent => dirent.isDirectory())
                .map(dirent => dirent.name);
            
            serviceDirs.forEach(serviceDir => {
                const depsFile = path.join(servicesPath, serviceDir, 'deps.yaml');
                if (fs.existsSync(depsFile)) {
                    const depsContent = fs.readFileSync(depsFile, 'utf8');
                    services[serviceDir] = yaml.load(depsContent);
                }
            });
        }
        
        return services;
    }

    /**
     * Load module definitions from deps.yaml files
     */
    loadModuleDefinitions() {
        const modules = {};
        const modulesPath = this.modulesDir;
        
        if (fs.existsSync(modulesPath)) {
            const moduleDirs = fs.readdirSync(modulesPath, { withFileTypes: true })
                .filter(dirent => dirent.isDirectory())
                .map(dirent => dirent.name);
            
            moduleDirs.forEach(moduleDir => {
                const depsFile = path.join(modulesPath, moduleDir, 'deps.yaml');
                if (fs.existsSync(depsFile)) {
                    const depsContent = fs.readFileSync(depsFile, 'utf8');
                    modules[moduleDir] = yaml.load(depsContent);
                }
            });
        }
        
        return modules;
    }

    /**
     * Create the base directory structure
     */
    async createBaseStructure() {
        const dirs = [
            'generated/services',
            'generated/modules', 
            'generated/docker',
            'generated/docs',
            'generated/scripts',
            'generated/tests'
        ];
        
        dirs.forEach(dir => {
            const fullPath = path.join(this.rootDir, dir);
            if (!fs.existsSync(fullPath)) {
                fs.mkdirSync(fullPath, { recursive: true });
            }
        });
        
        console.log('📁 Base directory structure created');
    }

    /**
     * Scaffold core services with microservices
     */
    async scaffoldCoreServices() {
        console.log('⚙️ Scaffolding Core Services...');
        
        const coreServices = [
            'auth-service',
            'billing-service', 
            'user-profile-service',
            'media-encoding-service',
            'streaming-service',
            'recommendation-engine',
            'chat-service',
            'notification-service',
            'analytics-service'
        ];

        for (const serviceName of coreServices) {
            await this.generateServiceBoilerplate(serviceName, 'service');
        }
    }

    /**
     * Scaffold business modules
     */
    async scaffoldBusinessModules() {
        console.log('🏢 Scaffolding Business Modules...');
        
        const businessModules = [
            'core-os',
            'puabo-dsp',
            'puabo-blac',
            'v-suite',
            'media-community',
            'business-tools',
            'integrations'
        ];

        for (const moduleName of businessModules) {
            await this.generateServiceBoilerplate(moduleName, 'module');
        }
    }

    /**
     * Generate service boilerplate code
     */
    async generateServiceBoilerplate(name, type) {
        const isService = type === 'service';
        const definition = isService ? this.serviceDefinitions[name] : this.moduleDefinitions[name];
        
        if (!definition) {
            console.log(`⚠️ No definition found for ${name}`);
            return;
        }

        const outputPath = path.join(this.outputDir, isService ? 'services' : 'modules', name);
        
        // Create service/module directory
        if (!fs.existsSync(outputPath)) {
            fs.mkdirSync(outputPath, { recursive: true });
        }

        // Generate main service file
        await this.generateMainServiceFile(outputPath, definition);
        
        // Generate microservices
        if (definition.microservices) {
            for (const microservice of definition.microservices) {
                await this.generateMicroserviceFile(outputPath, microservice, definition);
            }
        }

        // Generate API client for dependencies
        await this.generateAPIClient(outputPath, definition);
        
        // Generate Docker files
        await this.generateServiceDockerfile(outputPath, definition);
        
        console.log(`✅ Generated ${type}: ${name}`);
    }

    /**
     * Generate main service file (Express.js/FastAPI template)
     */
    async generateMainServiceFile(outputPath, definition) {
        const serviceName = definition.service?.name || definition.module?.name;
        const port = definition.service?.port || definition.module?.port;
        
        const template = `
// ${serviceName} - Generated by Nexus COS PF v1.2 Scaffolder
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || ${port};

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: '${serviceName}',
        timestamp: new Date().toISOString(),
        port: PORT
    });
});

// API Routes
${this.generateAPIRoutes(definition)}

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Internal Server Error', service: '${serviceName}' });
});

// Start server
app.listen(PORT, () => {
    console.log(\`🚀 \${serviceName} running on port \${PORT}\`);
    console.log(\`📊 Health check: http://localhost:\${PORT}/health\`);
});

module.exports = app;
`;

        fs.writeFileSync(path.join(outputPath, 'server.js'), template.trim());
    }

    /**
     * Generate API routes based on provides.apis in deps.yaml
     */
    generateAPIRoutes(definition) {
        if (!definition.provides?.apis) return '// No API endpoints defined';
        
        return definition.provides.apis.map(api => {
            const method = api.method.toLowerCase();
            const endpoint = api.endpoint;
            const description = api.description;
            
            return `
// ${description}
app.${method}('${endpoint}', async (req, res) => {
    try {
        // TODO: Implement ${description}
        res.json({ 
            message: '${description}',
            endpoint: '${endpoint}',
            method: '${api.method}',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});`;
        }).join('\\n');
    }

    /**
     * Generate microservice files
     */
    async generateMicroserviceFile(outputPath, microservice, parentDefinition) {
        const microservicePath = path.join(outputPath, 'microservices', microservice.name);
        
        if (!fs.existsSync(microservicePath)) {
            fs.mkdirSync(microservicePath, { recursive: true });
        }

        const template = `
// ${microservice.name} Microservice
// ${microservice.description}
// Part of ${parentDefinition.service?.name || parentDefinition.module?.name}

const express = require('express');
const app = express();
const PORT = process.env.PORT || ${microservice.port};

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        microservice: '${microservice.name}',
        description: '${microservice.description}',
        port: PORT
    });
});

// TODO: Implement microservice-specific endpoints

app.listen(PORT, () => {
    console.log(\`🔧 \${microservice.name} microservice running on port \${PORT}\`);
});

module.exports = app;
`;

        fs.writeFileSync(path.join(microservicePath, 'server.js'), template.trim());
    }

    /**
     * Generate API client for service dependencies
     */
    async generateAPIClient(outputPath, definition) {
        if (!definition.consumes?.apis) return;
        
        const clientTemplate = `
// API Client for ${definition.service?.name || definition.module?.name}
// Generated based on service dependencies

const axios = require('axios');

class APIClient {
    constructor() {
        this.baseURLs = {
${definition.consumes.apis.map(api => 
            `            '${api.service}': process.env.${api.service.toUpperCase().replace('-', '_')}_URL || 'http://localhost:3000'`
        ).join(',\\n')}
        };
    }

${definition.consumes.apis.map(api => `
    // ${api.purpose}
    async ${this.toCamelCase(api.service + '_' + api.endpoint.split('/').pop())}(data = {}) {
        try {
            const response = await axios({
                method: '${api.method || 'GET'}',
                url: \`\${this.baseURLs['${api.service}']}\${api.endpoint}\`,
                data: data
            });
            return response.data;
        } catch (error) {
            console.error(\`Error calling \${api.service}\${api.endpoint}:\`, error.message);
            throw error;
        }
    }`).join('\\n')}
}

module.exports = new APIClient();
`;

        fs.writeFileSync(path.join(outputPath, 'apiClient.js'), clientTemplate.trim());
    }

    /**
     * Generate Docker configurations
     */
    async generateDockerConfigs() {
        console.log('🐳 Generating Docker configurations...');
        
        // Generate main docker-compose.yml
        const dockerCompose = this.generateMainDockerCompose();
        fs.writeFileSync(path.join(this.outputDir, 'docker', 'docker-compose.yml'), dockerCompose);
        
        // Generate service-specific docker-compose files
        Object.keys(this.serviceDefinitions).forEach(serviceName => {
            const serviceCompose = this.generateServiceDockerCompose(serviceName, this.serviceDefinitions[serviceName]);
            fs.writeFileSync(path.join(this.outputDir, 'docker', `docker-compose.${serviceName}.yml`), serviceCompose);
        });
        
        console.log('✅ Docker configurations generated');
    }

    /**
     * Generate main docker-compose.yml for all services
     */
    generateMainDockerCompose() {
        return `
version: '3.8'

networks:
  nexus-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:

services:
  # Database Services
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: nexus_cos
      POSTGRES_USER: nexus_user
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - nexus-network
    ports:
      - "5432:5432"

  redis:
    image: redis:7
    volumes:
      - redis_data:/data
    networks:
      - nexus-network
    ports:
      - "6379:6379"

  # Core Services
${Object.entries(this.serviceDefinitions).map(([name, def]) => `
  ${name}:
    build: ../services/${name}
    ports:
      - "${def.service.port}:${def.service.port}"
    environment:
      - NODE_ENV=production
      - PORT=${def.service.port}
      - DATABASE_URL=postgresql://nexus_user:\${POSTGRES_PASSWORD}@postgres:5432/nexus_cos
    depends_on:
      - postgres
      - redis
    networks:
      - nexus-network`).join('')}

  # Business Modules  
${Object.entries(this.moduleDefinitions).map(([name, def]) => `
  ${name}:
    build: ../modules/${name}
    ports:
      - "${def.module.port}:${def.module.port}"
    environment:
      - NODE_ENV=production
      - PORT=${def.module.port}
    networks:
      - nexus-network`).join('')}
`;
    }

    /**
     * Generate service-specific Docker Compose
     */
    generateServiceDockerCompose(serviceName, definition) {
        return `
version: '3.8'

services:
  ${serviceName}:
    build: .
    ports:
      - "${definition.service.port}:${definition.service.port}"
    environment:
      - NODE_ENV=production
      - PORT=${definition.service.port}
${definition.microservices?.map(ms => `
  ${ms.name}:
    build: ./microservices/${ms.name}
    ports:
      - "${ms.port}:${ms.port}"
    environment:
      - NODE_ENV=production
      - PORT=${ms.port}`).join('') || ''}
`;
    }

    /**
     * Generate Dockerfile for service
     */
    async generateServiceDockerfile(outputPath, definition) {
        const dockerfile = `
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE ${definition.service?.port || definition.module?.port}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:${definition.service?.port || definition.module?.port}/health || exit 1

# Start application
CMD ["npm", "start"]
`;

        fs.writeFileSync(path.join(outputPath, 'Dockerfile'), dockerfile.trim());
    }

    /**
     * Generate deployment scripts
     */
    async generateDeploymentScripts() {
        console.log('📜 Generating deployment scripts...');
        
        const deployScript = `#!/bin/bash
# Nexus COS PF v1.2 Deployment Script
# Auto-generated by scaffolder

echo "🚀 Deploying Nexus COS PF v1.2..."

# Start core services in dependency order
${this.generateServiceStartupOrder()}

# Start business modules
${this.generateModuleStartupOrder()}

echo "✅ Nexus COS deployment complete!"
echo "📊 Check health: ./health-check.sh"
`;

        fs.writeFileSync(path.join(this.outputDir, 'scripts', 'deploy.sh'), deployScript);
        fs.chmodSync(path.join(this.outputDir, 'scripts', 'deploy.sh'), '755');
        
        console.log('✅ Deployment scripts generated');
    }

    /**
     * Generate service startup order based on dependencies
     */
    generateServiceStartupOrder() {
        // Services with no dependencies start first
        const startupOrder = [
            'auth-service',
            'billing-service',
            'user-profile-service',
            'media-encoding-service',
            'streaming-service',
            'recommendation-engine',
            'chat-service',
            'notification-service',
            'analytics-service'
        ];

        return startupOrder.map(service => 
            `echo "Starting ${service}..."\ndocker-compose up -d ${service}\nsleep 5`
        ).join('\\n');
    }

    /**
     * Generate module startup order
     */
    generateModuleStartupOrder() {
        const moduleOrder = [
            'core-os',
            'puabo-dsp', 
            'puabo-blac',
            'v-suite',
            'media-community',
            'business-tools',
            'integrations'
        ];

        return moduleOrder.map(module => 
            `echo "Starting ${module}..."\ndocker-compose up -d ${module}\nsleep 3`
        ).join('\\n');
    }

    /**
     * Utility function to convert to camelCase
     */
    toCamelCase(str) {
        return str.replace(/-([a-z])/g, (g) => g[1].toUpperCase());
    }
}

// Main execution
if (require.main === module) {
    const scaffolder = new NexusCOSScaffolder();
    scaffolder.scaffold().catch(console.error);
}

module.exports = NexusCOSScaffolder;