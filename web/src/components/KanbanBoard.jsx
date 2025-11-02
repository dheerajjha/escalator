import React from 'react';
import { format, formatDistanceToNow } from 'date-fns';
import './KanbanBoard.css';

const STAGES = [
  { id: 'active', name: 'Active', color: '#3b82f6' },
  { id: 'day2_nudge', name: 'Day 2 - Nudge', color: '#f59e0b' },
  { id: 'day4_second_nudge', name: 'Day 4 - 2nd Nudge', color: '#f97316' },
  { id: 'week1_call', name: 'Week 1 - Call', color: '#ef4444' },
  { id: 'manager_escalation', name: 'Manager Escalation', color: '#dc2626' },
  { id: 'resolved', name: 'Resolved', color: '#10b981' }
];

function KanbanBoard({ workItems, onWorkItemClick, onRefresh }) {
  const getItemsByStage = (stageId) => {
    return workItems.filter(item => item.current_stage === stageId);
  };

  const formatDate = (dateString) => {
    try {
      const date = new Date(dateString);
      return formatDistanceToNow(date, { addSuffix: true });
    } catch {
      return 'Unknown';
    }
  };

  const activeItems = workItems.filter(item => item.current_stage !== 'resolved');
  const resolvedItems = workItems.filter(item => item.current_stage === 'resolved');

  return (
    <div className="kanban-container">
      <div className="kanban-header">
        <h2>Your Work Items</h2>
        <div className="kanban-stats">
          <span className="stat">
            <strong>{activeItems.length}</strong> Active
          </span>
          <span className="stat">
            <strong>{resolvedItems.length}</strong> Resolved
          </span>
          <button className="btn-outline btn-sm" onClick={onRefresh}>
            Refresh
          </button>
        </div>
      </div>

      <div className="kanban-board">
        {STAGES.map(stage => {
          const items = getItemsByStage(stage.id);

          return (
            <div key={stage.id} className="kanban-column">
              <div className="column-header" style={{ borderTopColor: stage.color }}>
                <h3>{stage.name}</h3>
                <span className="item-count">{items.length}</span>
              </div>

              <div className="column-content">
                {items.length === 0 ? (
                  <div className="empty-state">
                    No items in this stage
                  </div>
                ) : (
                  items.map(item => (
                    <div
                      key={item.id}
                      className="work-item-card"
                      onClick={() => onWorkItemClick(item.id)}
                    >
                      <h4 className="item-title">{item.title}</h4>

                      {item.description && (
                        <p className="item-description">
                          {item.description.length > 100
                            ? `${item.description.substring(0, 100)}...`
                            : item.description}
                        </p>
                      )}

                      <div className="item-meta">
                        <div className="meta-row">
                          <span className="meta-label">POC:</span>
                          <span className="meta-value">{item.dependency_poc}</span>
                        </div>

                        {item.impact && (
                          <div className="meta-row">
                            <span className="meta-label">Impact:</span>
                            <span className="meta-value">{item.impact}</span>
                          </div>
                        )}

                        <div className="meta-row">
                          <span className="meta-label">Updated:</span>
                          <span className="meta-value">{formatDate(item.stage_updated_at)}</span>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default KanbanBoard;
