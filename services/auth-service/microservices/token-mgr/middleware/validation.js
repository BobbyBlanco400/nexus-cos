const Joi = require('joi');

// Admin registration validation schema
const adminRegisterSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
  password: Joi.string()
    .min(6)
    .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]'))
    .required()
    .messages({
      'string.min': 'Password must be at least 6 characters long',
      'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
      'any.required': 'Password is required'
    }),
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Name must be at least 2 characters long',
      'string.max': 'Name cannot exceed 100 characters',
      'any.required': 'Name is required'
    }),
  username: Joi.string()
    .min(3)
    .max(50)
    .alphanum()
    .optional()
    .messages({
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username cannot exceed 50 characters',
      'string.alphanum': 'Username can only contain alphanumeric characters'
    }),
  role: Joi.string()
    .valid('ADMIN', 'SUPER_ADMIN')
    .default('ADMIN')
    .optional(),
  permissions: Joi.array()
    .items(
      Joi.string().valid(
        'MANAGE_USERS',
        'MANAGE_CONTENT', 
        'MANAGE_SETTINGS',
        'MANAGE_BILLING',
        'MANAGE_ANALYTICS',
        'MANAGE_SYSTEM',
        'VIEW_LOGS',
        'MANAGE_ROLES'
      )
    )
    .optional()
});

// Admin creation validation schema (similar but allows for different use case)
const adminCreateSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
  password: Joi.string()
    .min(6)
    .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]'))
    .required()
    .messages({
      'string.min': 'Password must be at least 6 characters long',
      'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
      'any.required': 'Password is required'
    }),
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Name must be at least 2 characters long',
      'string.max': 'Name cannot exceed 100 characters',
      'any.required': 'Name is required'
    }),
  username: Joi.string()
    .min(3)
    .max(50)
    .alphanum()
    .required()
    .messages({
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username cannot exceed 50 characters',
      'string.alphanum': 'Username can only contain alphanumeric characters',
      'any.required': 'Username is required'
    }),
  role: Joi.string()
    .valid('ADMIN', 'SUPER_ADMIN')
    .default('SUPER_ADMIN')
    .optional(),
  permissions: Joi.array()
    .items(
      Joi.string().valid(
        'MANAGE_USERS',
        'MANAGE_CONTENT', 
        'MANAGE_SETTINGS',
        'MANAGE_BILLING',
        'MANAGE_ANALYTICS',
        'MANAGE_SYSTEM',
        'VIEW_LOGS',
        'MANAGE_ROLES'
      )
    )
    .optional()
});

// Login validation schema
const adminLoginSchema = Joi.object({
  login: Joi.alternatives()
    .try(
      Joi.string().email(),
      Joi.string().min(3).max(50).alphanum()
    )
    .required()
    .messages({
      'any.required': 'Email or username is required',
      'alternatives.match': 'Please provide a valid email or username'
    }),
  password: Joi.string()
    .required()
    .messages({
      'any.required': 'Password is required'
    })
});

// Validation middleware factory
const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const validationErrors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: validationErrors
      });
    }

    req.validatedBody = value;
    next();
  };
};

module.exports = {
  validateAdminRegister: validateRequest(adminRegisterSchema),
  validateAdminCreate: validateRequest(adminCreateSchema),
  validateAdminLogin: validateRequest(adminLoginSchema)
};