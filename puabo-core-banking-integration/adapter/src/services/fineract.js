import axios from 'axios';
import config from '../config.js';

const api = axios.create({
  baseURL: config.FINERACT_BASE,
  headers: { 'Content-Type': 'application/json' }
});

export async function createCustomer(payload) {
  const res = await api.post('/clients', payload);
  return res.data;
}

export async function createLoan(payload) {
  const res = await api.post('/loans', payload);
  return res.data;
}

export async function postPayment(loanId, payload) {
  const res = await api.post(`/loans/${loanId}/transactions?command=repayment`, payload);
  return res.data;
}
