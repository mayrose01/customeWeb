import axios from './axios';

export function getServices() {
  return axios.get('/service/');
}

export function createService(data) {
  return axios.post('/service/', data);
}

export function updateService(id, data) {
  return axios.put(`/service/${id}`, data);
}

export function deleteService(id) {
  return axios.delete(`/service/${id}`);
} 