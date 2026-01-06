import { useState } from 'react';
import './CreatorOnboardingForm.css';

interface FormData {
  tenantName: string;
  slug: string;
  domain: string;
  category: string;
  description: string;
  email: string;
}

export default function CreatorOnboardingForm() {
  const [formData, setFormData] = useState<FormData>({
    tenantName: '',
    slug: '',
    domain: '',
    category: '',
    description: '',
    email: '',
  });

  const [submitted, setSubmitted] = useState(false);
  const [cliCommand, setCliCommand] = useState('');
  const [errors, setErrors] = useState<Partial<Record<keyof FormData, string>>>({});

  const categories = [
    'Entertainment & Lifestyle',
    'Health & Wellness',
    'Food & Community',
    'Gaming & Esports',
    'Talk & Discussion',
    'Urban Entertainment',
    'Dance & Performing Arts',
    'Creative Arts',
    'Beauty & Fashion',
    'Family & Children',
    'Comedy & Entertainment',
    'Local Community',
    'Food & Lifestyle',
    'Technology & Education',
    'Music & Audio',
    'Other',
  ];

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    // Auto-generate slug from tenant name
    if (name === 'tenantName' && !formData.slug) {
      const generatedSlug = value
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .trim();
      setFormData(prev => ({ ...prev, slug: generatedSlug }));
    }
    
    // Auto-generate domain from slug
    if (name === 'slug') {
      const generatedDomain = `${value}.n3xuscos.online`;
      setFormData(prev => ({ ...prev, domain: generatedDomain }));
    }
    
    // Clear error for this field
    if (errors[name as keyof FormData]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Partial<Record<keyof FormData, string>> = {};
    
    if (!formData.tenantName.trim()) {
      newErrors.tenantName = 'Platform name is required';
    }
    
    if (!formData.slug.trim()) {
      newErrors.slug = 'Slug is required';
    } else if (!/^[a-z0-9-]+$/.test(formData.slug)) {
      newErrors.slug = 'Slug must contain only lowercase letters, numbers, and hyphens';
    }
    
    if (!formData.domain.trim()) {
      newErrors.domain = 'Domain is required';
    }
    
    if (!formData.category) {
      newErrors.category = 'Please select a category';
    }
    
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email address';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }
    
    // Generate CLI command
    const command = `./infra/cps/scripts/deploy-tenant.sh "${formData.tenantName}" "${formData.slug}" "${formData.domain}"`;
    setCliCommand(command);
    setSubmitted(true);
    
    console.log('🚀 Creator Onboarding Form Submitted:', formData);
  };

  const handleReset = () => {
    setFormData({
      tenantName: '',
      slug: '',
      domain: '',
      category: '',
      description: '',
      email: '',
    });
    setSubmitted(false);
    setCliCommand('');
    setErrors({});
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(cliCommand);
    alert('CLI command copied to clipboard!');
  };

  if (submitted) {
    return (
      <div className="onboarding-success">
        <div className="success-icon">✅</div>
        <h2>Creator Platform Ready for Deployment!</h2>
        
        <div className="success-details">
          <h3>Platform Details:</h3>
          <ul>
            <li><strong>Name:</strong> {formData.tenantName}</li>
            <li><strong>Slug:</strong> {formData.slug}</li>
            <li><strong>Domain:</strong> {formData.domain}</li>
            <li><strong>Category:</strong> {formData.category}</li>
          </ul>
        </div>

        <div className="cli-command-section">
          <h3>Deployment Command:</h3>
          <p>Run this command to deploy the platform:</p>
          
          <div className="cli-command-box">
            <code>{cliCommand}</code>
            <button onClick={copyToClipboard} className="copy-btn" title="Copy to clipboard">
              📋 Copy
            </button>
          </div>
        </div>

        <div className="next-steps">
          <h3>Next Steps:</h3>
          <ol>
            <li>Copy the deployment command above</li>
            <li>SSH into your N3XUS COS server</li>
            <li>Run the deployment command</li>
            <li>Platform will be live in ~10 minutes</li>
            <li>Check status at <code>/dashboard</code></li>
          </ol>
        </div>

        <div className="success-actions">
          <button onClick={handleReset} className="btn-secondary">
            Onboard Another Creator
          </button>
          <a href="/residents" className="btn-primary">
            View Founding Residents
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="onboarding-form-container">
      <div className="form-intro">
        <h3>Deploy a New Creator Platform</h3>
        <p>
          Fill out the form below to generate deployment configuration for a new creator platform.
          No technical knowledge required — we'll generate everything you need.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="onboarding-form">
        <div className="form-group">
          <label htmlFor="tenantName">
            Platform Name <span className="required">*</span>
          </label>
          <input
            type="text"
            id="tenantName"
            name="tenantName"
            value={formData.tenantName}
            onChange={handleChange}
            placeholder="e.g., My Creator Platform"
            className={errors.tenantName ? 'error' : ''}
          />
          {errors.tenantName && <span className="error-message">{errors.tenantName}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="slug">
            URL Slug <span className="required">*</span>
          </label>
          <input
            type="text"
            id="slug"
            name="slug"
            value={formData.slug}
            onChange={handleChange}
            placeholder="e.g., my-creator-platform"
            className={errors.slug ? 'error' : ''}
          />
          <small>Lowercase letters, numbers, and hyphens only. Auto-generated from platform name.</small>
          {errors.slug && <span className="error-message">{errors.slug}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="domain">
            Domain <span className="required">*</span>
          </label>
          <input
            type="text"
            id="domain"
            name="domain"
            value={formData.domain}
            onChange={handleChange}
            placeholder="e.g., myplatform.n3xuscos.online"
            className={errors.domain ? 'error' : ''}
            readOnly
          />
          <small>Auto-generated from slug. Custom domains can be configured after deployment.</small>
          {errors.domain && <span className="error-message">{errors.domain}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="category">
            Category <span className="required">*</span>
          </label>
          <select
            id="category"
            name="category"
            value={formData.category}
            onChange={handleChange}
            className={errors.category ? 'error' : ''}
          >
            <option value="">Select a category</option>
            {categories.map(cat => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
          {errors.category && <span className="error-message">{errors.category}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="description">
            Description
          </label>
          <textarea
            id="description"
            name="description"
            value={formData.description}
            onChange={handleChange}
            placeholder="Brief description of your platform (optional)"
            rows={4}
          />
        </div>

        <div className="form-group">
          <label htmlFor="email">
            Contact Email <span className="required">*</span>
          </label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            placeholder="you@example.com"
            className={errors.email ? 'error' : ''}
          />
          <small>For deployment notifications and platform updates.</small>
          {errors.email && <span className="error-message">{errors.email}</span>}
        </div>

        <div className="form-actions">
          <button type="button" onClick={handleReset} className="btn-secondary">
            Reset Form
          </button>
          <button type="submit" className="btn-primary">
            Generate Deployment Command
          </button>
        </div>
      </form>

      <div className="form-footer">
        <p>
          <strong>Note:</strong> After submitting, you'll receive a deployment command to run on your server.
          The platform will be live in approximately 10 minutes.
        </p>
      </div>
    </div>
  );
}
