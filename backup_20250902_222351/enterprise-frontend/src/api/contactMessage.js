import axios from './axios';

export function getContactMessages(params) {
  return axios.get('/contact-message/', { params });
}

export function getContactMessage(id) {
  return axios.get(`/contact-message/${id}`);
}

export function createContactMessage(data) {
  return axios.post('/contact-message/', data);
}

export function deleteContactMessage(id) {
  return axios.delete(`/contact-message/${id}`);
} 