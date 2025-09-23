import express from 'express';

const router: express.Router = express.Router();

// GET /api/blac/applications
router.get('/applications', (req, res) => {
  res.json({
    success: true,
    data: {
      applications: [
        {
          id: '1',
          type: 'equipment-loan',
          amount: 15000,
          purpose: 'Professional streaming equipment',
          status: 'pending',
          submittedDate: new Date(Date.now() - 5 * 86400000).toISOString(),
          documents: ['identity', 'income']
        },
        {
          id: '2',
          type: 'studio-upgrade',
          amount: 8500,
          purpose: 'Home studio renovation',
          status: 'approved',
          submittedDate: new Date(Date.now() - 15 * 86400000).toISOString(),
          approvedDate: new Date(Date.now() - 2 * 86400000).toISOString(),
          documents: ['identity', 'income', 'business-plan']
        }
      ]
    },
    message: 'Applications retrieved successfully'
  });
});

// POST /api/blac/apply
router.post('/apply', (req, res) => {
  const { type, amount, purpose, documents } = req.body;
  
  res.json({
    success: true,
    data: {
      application: {
        id: Date.now().toString(),
        type,
        amount,
        purpose,
        status: 'submitted',
        submittedDate: new Date().toISOString(),
        documents: documents || [],
        referenceNumber: 'BLAC-' + Math.random().toString(36).substr(2, 8).toUpperCase()
      }
    },
    message: 'Application submitted successfully'
  });
});

// GET /api/blac/application/:id
router.get('/application/:id', (req, res) => {
  const { id } = req.params;
  
  res.json({
    success: true,
    data: {
      application: {
        id,
        type: 'equipment-loan',
        amount: 15000,
        purpose: 'Professional streaming equipment',
        status: 'under-review',
        submittedDate: new Date(Date.now() - 5 * 86400000).toISOString(),
        documents: ['identity', 'income'],
        timeline: [
          {
            status: 'submitted',
            date: new Date(Date.now() - 5 * 86400000).toISOString(),
            note: 'Application submitted'
          },
          {
            status: 'under-review',
            date: new Date(Date.now() - 3 * 86400000).toISOString(),
            note: 'Application is being reviewed by our team'
          }
        ]
      }
    },
    message: 'Application details retrieved successfully'
  });
});

// POST /api/blac/upload-document
router.post('/upload-document', (req, res) => {
  const { applicationId, documentType } = req.body;
  
  // TODO: Implement file upload with multer
  res.json({
    success: true,
    data: {
      document: {
        id: Date.now().toString(),
        applicationId,
        type: documentType,
        filename: 'document.pdf',
        uploadDate: new Date().toISOString(),
        status: 'uploaded'
      }
    },
    message: 'Document uploaded successfully'
  });
});

// GET /api/blac/loan-types
router.get('/loan-types', (req, res) => {
  res.json({
    success: true,
    data: {
      loanTypes: [
        {
          id: 'equipment-loan',
          name: 'Equipment Loan',
          description: 'Funding for professional content creation equipment',
          minAmount: 1000,
          maxAmount: 50000,
          interestRate: 5.9,
          term: '12-36 months',
          requirements: ['identity', 'income', 'equipment-quote']
        },
        {
          id: 'business-expansion',
          name: 'Business Expansion Loan',
          description: 'Capital for scaling your creator business',
          minAmount: 5000,
          maxAmount: 100000,
          interestRate: 6.5,
          term: '24-60 months',
          requirements: ['identity', 'income', 'business-plan', 'financial-statements']
        },
        {
          id: 'studio-setup',
          name: 'Studio Setup Loan',
          description: 'Funding for home studio construction or renovation',
          minAmount: 2000,
          maxAmount: 75000,
          interestRate: 5.5,
          term: '12-48 months',
          requirements: ['identity', 'income', 'construction-estimate']
        }
      ]
    },
    message: 'Loan types retrieved successfully'
  });
});

export default router;