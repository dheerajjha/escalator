import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getUserWorkItems, getPendingReminders } from '../services/api';
import KanbanBoard from './KanbanBoard';
import CreateWorkItemModal from './CreateWorkItemModal';
import './Dashboard.css';

function Dashboard({ user, onLogout }) {
  const [workItems, setWorkItems] = useState([]);
  const [reminders, setReminders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const navigate = useNavigate();

  const loadData = async () => {
    try {
      setLoading(true);
      const [itemsRes, remindersRes] = await Promise.all([
        getUserWorkItems(user.id),
        getPendingReminders()
      ]);
      setWorkItems(itemsRes.data);
      setReminders(remindersRes.data);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [user.id]);

  const handleWorkItemCreated = () => {
    setShowCreateModal(false);
    loadData();
  };

  const handleWorkItemClick = (workItemId) => {
    navigate(`/work-item/${workItemId}`);
  };

  const upcomingReminders = reminders.filter(r => r.work_item_id);

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="dashboard-header-content">
          <div>
            <h1>Escalator</h1>
            <p className="user-info">
              Welcome back, <strong>{user.display_name}</strong> (@{user.username})
              <span className="user-role"> • {user.role}</span>
            </p>
          </div>
          <div className="header-actions">
            <button
              className="btn-primary"
              onClick={() => setShowCreateModal(true)}
            >
              + New Work Item
            </button>
            <button className="btn-outline" onClick={onLogout}>
              Logout
            </button>
          </div>
        </div>
      </header>

      {upcomingReminders.length > 0 && (
        <div className="reminders-banner">
          <h3>⏰ Upcoming Reminders ({upcomingReminders.length})</h3>
          <div className="reminders-list">
            {upcomingReminders.slice(0, 3).map(reminder => (
              <div key={reminder.id} className="reminder-item">
                <span className="reminder-title">{reminder.title}</span>
                <span className="reminder-type">{reminder.reminder_type.replace('_', ' ')}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="dashboard-content">
        {loading ? (
          <div className="loading-state">
            <div className="spinner"></div>
            <p>Loading your work items...</p>
          </div>
        ) : (
          <KanbanBoard
            workItems={workItems}
            onWorkItemClick={handleWorkItemClick}
            onRefresh={loadData}
          />
        )}
      </div>

      {showCreateModal && (
        <CreateWorkItemModal
          userId={user.id}
          onClose={() => setShowCreateModal(false)}
          onCreated={handleWorkItemCreated}
        />
      )}
    </div>
  );
}

export default Dashboard;
