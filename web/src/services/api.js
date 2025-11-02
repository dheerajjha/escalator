import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://194.195.117.157:5230/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Users
export const createUser = (displayName, role = 'senior') =>
  api.post('/users/onboard', { displayName, role });

export const getUser = (userId) =>
  api.get(`/users/${userId}`);

export const updateFcmToken = (userId, fcmToken) =>
  api.put(`/users/${userId}/fcm-token`, { fcmToken });

// Work Items
export const createWorkItem = (workItem) =>
  api.post('/work-items', workItem);

export const getUserWorkItems = (userId) =>
  api.get(`/work-items/user/${userId}`);

export const getWorkItem = (workItemId) =>
  api.get(`/work-items/${workItemId}`);

export const updateWorkItem = (workItemId, updates) =>
  api.put(`/work-items/${workItemId}`, updates);

export const deleteWorkItem = (workItemId) =>
  api.delete(`/work-items/${workItemId}`);

export const resolveWorkItem = (workItemId, notes = '') =>
  api.post(`/work-items/${workItemId}/resolve`, { notes });

// Escalations
export const escalateWorkItem = (workItemId, notes = '') =>
  api.post(`/escalations/${workItemId}/escalate`, { notes });

export const getEscalationHistory = (workItemId) =>
  api.get(`/escalations/${workItemId}/history`);

export const getPendingReminders = () =>
  api.get('/escalations/reminders/pending');

// Standup Updates
export const addStandupUpdate = (workItemId, updateText, date = null) =>
  api.post('/standups', { workItemId, updateText, date });

export const getWorkItemStandups = (workItemId) =>
  api.get(`/standups/work-item/${workItemId}`);

export const getUserStandups = (userId) =>
  api.get(`/standups/user/${userId}`);

export const getStandupsByDate = (date, userId = null) => {
  const params = userId ? `?userId=${userId}` : '';
  return api.get(`/standups/date/${date}${params}`);
};

export const deleteStandupUpdate = (standupId) =>
  api.delete(`/standups/${standupId}`);

export default api;
