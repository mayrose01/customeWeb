import axios from './axios';

export function getCompanyInfo() {
  return axios.get('/company/');
}

export function createCompanyInfo(data) {
  return axios.post('/company/', data);
}

export function updateCompanyInfo(data) {
  return axios.put('/company/', data);
}

export function deleteCompanyInfo() {
  return axios.delete('/company/');
} 