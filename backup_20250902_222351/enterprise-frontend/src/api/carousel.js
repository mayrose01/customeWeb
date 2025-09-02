import axios from './axios';

export function getCarouselImages() {
  return axios.get('/carousel/');
}

export function createCarouselImage(data) {
  return axios.post('/carousel/', data);
}

export function updateCarouselImage(id, data) {
  return axios.put(`/carousel/${id}`, data);
}

export function deleteCarouselImage(id) {
  return axios.delete(`/carousel/${id}`);
} 