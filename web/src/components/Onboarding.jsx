import React, { useState } from 'react';
import { createUser } from '../services/api';
import './Onboarding.css';

function Onboarding({ onUserCreated }) {
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState('senior');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!displayName.trim()) {
      setError('Please enter your name');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await createUser(displayName.trim(), role);
      const { user, isNewUser, message } = response.data;

      // Show welcome message in console
      if (!isNewUser) {
        console.log('Welcome back!', user.display_name);
      }

      onUserCreated(user);
    } catch (err) {
      console.error('Error onboarding user:', err);
      setError('Failed to sign in. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="onboarding-container">
      <div className="onboarding-card">
        <div className="onboarding-header">
          <h1>Welcome to Escalator</h1>
          <p>Track your work and escalate blockers effectively</p>
        </div>

        <form onSubmit={handleSubmit} className="onboarding-form">
          <div className="form-group">
            <label htmlFor="displayName" className="form-label">
              What should we call you?
            </label>
            <input
              id="displayName"
              type="text"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Enter your name"
              autoFocus
              disabled={loading}
            />
            <p className="form-help">
              Enter the same name to access your existing dashboard
            </p>
          </div>

          <div className="form-group">
            <label htmlFor="role" className="form-label">
              Your role
            </label>
            <select
              id="role"
              value={role}
              onChange={(e) => setRole(e.target.value)}
              disabled={loading}
            >
              <option value="junior">Junior Engineer</option>
              <option value="senior">Senior Engineer</option>
              <option value="principal">Principal Engineer</option>
            </select>
            <p className="form-help">
              This helps customize your escalation workflow
            </p>
          </div>

          {error && (
            <div className="error-message">
              {error}
            </div>
          )}

          <button
            type="submit"
            className="btn-primary onboarding-submit"
            disabled={loading}
          >
            {loading ? 'Signing in...' : 'Continue'}
          </button>
        </form>

        <div className="onboarding-footer">
          <p>
            Escalator helps you track work items and follow systematic
            escalation patterns when you're blocked.
          </p>
        </div>
      </div>
    </div>
  );
}

export default Onboarding;
