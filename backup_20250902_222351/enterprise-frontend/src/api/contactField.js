import axios from './axios';

export function getContactFields() {
  return axios.get('/contact-field/');
}

export function createContactField(data) {
  return axios.post('/contact-field/', data);
}

export function updateContactField(id, data) {
  return axios.put(`/contact-field/${id}`, data);
}

export function deleteContactField(id) {
  return axios.delete(`/contact-field/${id}`);
} 