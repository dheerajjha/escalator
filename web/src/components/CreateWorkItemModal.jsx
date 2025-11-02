import React, { useState } from 'react';
import { createWorkItem } from '../services/api';

function CreateWorkItemModal({ userId, onClose, onCreated }) {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    dependencyPoc: '',
    pocEmail: '',
    impact: '',
    managerName: '',
    managerEmail: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.title.trim() || !formData.dependencyPoc.trim()) {
      setError('Title and Dependency POC are required');
      return;
    }

    setLoading(true);
    setError('');

    try {
      await createWorkItem({
        userId,
        ...formData
      });
      onCreated();
    } catch (err) {
      console.error('Error creating work item:', err);
      setError('Failed to create work item. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2 className="modal-title">Create New Work Item</h2>
          <button onClick={onClose} className="btn-outline btn-sm">
            Close
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="form-group">
              <label htmlFor="title" className="form-label">
                Title *
              </label>
              <input
                id="title"
                name="title"
                type="text"
                value={formData.title}
                onChange={handleChange}
                placeholder="Brief description of the work"
                autoFocus
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="description" className="form-label">
                Description
              </label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                placeholder="Detailed description of what needs to be done"
                rows={3}
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="dependencyPoc" className="form-label">
                Dependency POC *
              </label>
              <input
                id="dependencyPoc"
                name="dependencyPoc"
                type="text"
                value={formData.dependencyPoc}
                onChange={handleChange}
                placeholder="Person you're waiting on (e.g., Mudit)"
                disabled={loading}
              />
              <p className="form-help">
                The person whose response you're waiting for
              </p>
            </div>

            <div className="form-group">
              <label htmlFor="pocEmail" className="form-label">
                POC Email
              </label>
              <input
                id="pocEmail"
                name="pocEmail"
                type="email"
                value={formData.pocEmail}
                onChange={handleChange}
                placeholder="poc@company.com"
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="impact" className="form-label">
                Impact
              </label>
              <textarea
                id="impact"
                name="impact"
                value={formData.impact}
                onChange={handleChange}
                placeholder="What's the impact of this delay? (e.g., Blocking feature X, delaying release by Y days)"
                rows={2}
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="managerName" className="form-label">
                Manager Name
              </label>
              <input
                id="managerName"
                name="managerName"
                type="text"
                value={formData.managerName}
                onChange={handleChange}
                placeholder="For escalation if needed"
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="managerEmail" className="form-label">
                Manager Email
              </label>
              <input
                id="managerEmail"
                name="managerEmail"
                type="email"
                value={formData.managerEmail}
                onChange={handleChange}
                placeholder="manager@company.com"
                disabled={loading}
              />
            </div>

            {error && (
              <div className="error-message">
                {error}
              </div>
            )}
          </div>

          <div className="modal-footer">
            <button
              type="button"
              className="btn-outline"
              onClick={onClose}
              disabled={loading}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="btn-primary"
              disabled={loading}
            >
              {loading ? 'Creating...' : 'Create Work Item'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default CreateWorkItemModal;
