import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import {
  getWorkItem,
  escalateWorkItem,
  resolveWorkItem,
  addStandupUpdate,
  deleteWorkItem
} from '../services/api';
import './WorkItemDetail.css';

const STAGE_INFO = {
  'active': {
    name: 'Active',
    description: 'Waiting for response',
    nextAction: 'Nudge offline + standup update'
  },
  'day2_nudge': {
    name: 'Day 2 - Nudge Offline',
    description: 'First nudge sent',
    nextAction: 'Second nudge + call out in standup'
  },
  'day4_second_nudge': {
    name: 'Day 4 - Second Nudge',
    description: 'Second nudge sent',
    nextAction: 'Setup call with POC'
  },
  'week1_call': {
    name: 'Week 1 - Setup Call',
    description: 'Call scheduled/attempted',
    nextAction: 'Escalate to manager'
  },
  'manager_escalation': {
    name: 'Manager Escalation',
    description: 'Escalated to manager',
    nextAction: 'Final stage'
  },
  'resolved': {
    name: 'Resolved',
    description: 'Work item completed',
    nextAction: 'None'
  }
};

function WorkItemDetail({ user }) {
  const { id } = useParams();
  const navigate = useNavigate();
  const [workItem, setWorkItem] = useState(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [showStandupModal, setShowStandupModal] = useState(false);
  const [standupText, setStandupText] = useState('');

  const loadWorkItem = async () => {
    try {
      setLoading(true);
      const response = await getWorkItem(id);
      setWorkItem(response.data);
    } catch (error) {
      console.error('Error loading work item:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadWorkItem();
  }, [id]);

  const handleEscalate = async () => {
    if (!confirm('Are you sure you want to escalate this work item to the next stage?')) {
      return;
    }

    setActionLoading(true);
    try {
      await escalateWorkItem(id);
      await loadWorkItem();
    } catch (error) {
      console.error('Error escalating work item:', error);
      alert('Failed to escalate work item');
    } finally {
      setActionLoading(false);
    }
  };

  const handleResolve = async () => {
    const notes = prompt('Add resolution notes (optional):');
    if (notes === null) return;

    setActionLoading(true);
    try {
      await resolveWorkItem(id, notes);
      await loadWorkItem();
    } catch (error) {
      console.error('Error resolving work item:', error);
      alert('Failed to resolve work item');
    } finally {
      setActionLoading(false);
    }
  };

  const handleAddStandup = async () => {
    if (!standupText.trim()) return;

    setActionLoading(true);
    try {
      await addStandupUpdate(id, standupText);
      setStandupText('');
      setShowStandupModal(false);
      await loadWorkItem();
    } catch (error) {
      console.error('Error adding standup update:', error);
      alert('Failed to add standup update');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this work item? This cannot be undone.')) {
      return;
    }

    setActionLoading(true);
    try {
      await deleteWorkItem(id);
      navigate('/dashboard');
    } catch (error) {
      console.error('Error deleting work item:', error);
      alert('Failed to delete work item');
      setActionLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
      </div>
    );
  }

  if (!workItem) {
    return (
      <div className="error-container">
        <p>Work item not found</p>
        <button className="btn-primary" onClick={() => navigate('/dashboard')}>
          Back to Dashboard
        </button>
      </div>
    );
  }

  const stageInfo = STAGE_INFO[workItem.current_stage];
  const canEscalate = workItem.current_stage !== 'resolved' && workItem.current_stage !== 'manager_escalation';
  const canResolve = workItem.current_stage !== 'resolved';

  return (
    <div className="work-item-detail">
      <header className="detail-header">
        <div className="header-content">
          <button className="btn-outline" onClick={() => navigate('/dashboard')}>
            ← Back to Dashboard
          </button>
          <div className="header-actions">
            <button
              className="btn-outline"
              onClick={() => setShowStandupModal(true)}
              disabled={actionLoading || workItem.current_stage === 'resolved'}
            >
              + Add Standup Update
            </button>
            <button
              className="btn-danger"
              onClick={handleDelete}
              disabled={actionLoading}
            >
              Delete
            </button>
          </div>
        </div>
      </header>

      <div className="detail-content">
        <div className="detail-main">
          <div className="card">
            <div className="stage-badge" style={{
              backgroundColor: workItem.current_stage === 'resolved' ? '#10b981' : '#ef4444'
            }}>
              {stageInfo.name}
            </div>

            <h1 className="work-item-title">{workItem.title}</h1>

            {workItem.description && (
              <p className="work-item-description">{workItem.description}</p>
            )}

            <div className="info-grid">
              <div className="info-item">
                <label>Dependency POC</label>
                <p>{workItem.dependency_poc}</p>
              </div>

              {workItem.poc_email && (
                <div className="info-item">
                  <label>POC Email</label>
                  <p>{workItem.poc_email}</p>
                </div>
              )}

              {workItem.impact && (
                <div className="info-item">
                  <label>Impact</label>
                  <p>{workItem.impact}</p>
                </div>
              )}

              {workItem.manager_name && (
                <div className="info-item">
                  <label>Manager</label>
                  <p>{workItem.manager_name}</p>
                </div>
              )}
            </div>

            <div className="action-section">
              <div className="next-action">
                <strong>Next Action:</strong> {stageInfo.nextAction}
              </div>

              <div className="action-buttons">
                {canResolve && (
                  <button
                    className="btn-success"
                    onClick={handleResolve}
                    disabled={actionLoading}
                  >
                    Mark as Resolved
                  </button>
                )}

                {canEscalate && (
                  <button
                    className="btn-primary"
                    onClick={handleEscalate}
                    disabled={actionLoading}
                  >
                    Escalate to Next Stage
                  </button>
                )}
              </div>
            </div>
          </div>

          {workItem.standups && workItem.standups.length > 0 && (
            <div className="card">
              <h2>Standup Updates ({workItem.standups.length})</h2>
              <div className="standup-list">
                {workItem.standups.map(standup => (
                  <div key={standup.id} className="standup-item">
                    <div className="standup-date">
                      {format(new Date(standup.date), 'MMM d, yyyy')}
                    </div>
                    <div className="standup-text">{standup.update_text}</div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="detail-sidebar">
          <div className="card">
            <h3>Escalation History</h3>
            <div className="history-timeline">
              {workItem.history && workItem.history.map(entry => (
                <div key={entry.id} className="history-entry">
                  <div className="history-dot"></div>
                  <div className="history-content">
                    <div className="history-stage">{entry.action_taken}</div>
                    {entry.notes && (
                      <div className="history-notes">{entry.notes}</div>
                    )}
                    <div className="history-time">
                      {format(new Date(entry.timestamp), 'MMM d, yyyy h:mm a')}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {showStandupModal && (
        <div className="modal-overlay" onClick={() => setShowStandupModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Add Standup Update</h2>
              <button className="btn-outline btn-sm" onClick={() => setShowStandupModal(false)}>
                Close
              </button>
            </div>
            <div className="modal-body">
              <textarea
                value={standupText}
                onChange={(e) => setStandupText(e.target.value)}
                placeholder="What's the update for standup?"
                rows={4}
                autoFocus
              />
            </div>
            <div className="modal-footer">
              <button className="btn-outline" onClick={() => setShowStandupModal(false)}>
                Cancel
              </button>
              <button
                className="btn-primary"
                onClick={handleAddStandup}
                disabled={!standupText.trim() || actionLoading}
              >
                Add Update
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default WorkItemDetail;
