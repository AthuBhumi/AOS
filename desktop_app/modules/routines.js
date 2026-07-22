/**
 * Modules 05, 06, 08 — Habits, Streaks, Daily Quests & OKR Goals
 */

function renderRoutinesModule(state) {
    const habits = state.habits;
    const goals = state.goals;

    const habitsHtml = habits.map(h => `
        <div class="list-row">
            <div class="check-circle ${h.doneToday ? 'checked' : ''}" onclick="window.aosStorage.toggleHabit('${h.id}'); window.aosApp.refresh();">
                ${h.doneToday ? '✓' : ''}
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700; ${h.doneToday ? 'text-decoration: line-through; color: var(--text-tertiary);' : ''}">${h.name}</div>
                <div style="font-size: 11px; color: var(--text-tertiary);">${h.category}</div>
            </div>
            <span class="chip orange">${h.streak} DAYS 🔥</span>
        </div>
    `).join('');

    const goalsHtml = goals.map(g => `
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-line); padding: 14px; border-radius: 14px;">
            <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 6px;">
                <span>${g.title}</span>
                <span style="color: var(--accent-blue);">${g.progress}%</span>
            </div>
            <div class="progress-container">
                <div class="progress-fill" style="width: ${g.progress}%;"></div>
            </div>
        </div>
    `).join('');

    return `
        <div class="grid-2">
            <!-- Atomic Habits -->
            <div class="card">
                <span class="card-title">ATOMIC HABITS & DAILY STREAKS (MODULE 05)</span>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${habitsHtml}
                </div>
            </div>

            <!-- OKR Goals -->
            <div class="card">
                <span class="card-title">QUARTERLY OKRS & GOALS (MODULE 08)</span>
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    ${goalsHtml}
                </div>
            </div>
        </div>
    `;
}

window.renderRoutinesModule = renderRoutinesModule;
