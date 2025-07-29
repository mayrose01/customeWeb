import axios from './axios';

export function getInquiries(params) {
  return axios.get('/inquiry/', { params });
}

export function getInquiry(id) {
  return axios.get(`/inquiry/${id}`);
}

export function createInquiry(data) {
  return axios.post('/inquiry/', data);
}

export function updateInquiry(id, data) {
  return axios.put(`/inquiry/${id}`, data);
}

export function deleteInquiry(id) {
  return axios.delete(`/inquiry/${id}`);
} 