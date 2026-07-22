/**
 * Module 01 — Executive Console & RPG Developer System
 */

function renderConsoleModule(state) {
    const user = state.user;
    const missions = state.missions;

    const missionsHtml = missions.map(m => `
        <div class="list-row">
            <div class="check-circle ${m.done ? 'checked' : ''}" onclick="window.aosStorage.toggleMission('${m.id}'); window.aosApp.refresh();">
                ${m.done ? '✓' : ''}
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 600; ${m.done ? 'text-decoration: line-through; color: var(--text-tertiary);' : ''}">
                    ${m.title}
                </div>
                <div style="font-size: 10px; color: var(--text-tertiary);">${m.category}</div>
            </div>
            <span class="chip blue">+${m.xp} XP</span>
        </div>
    `).join('');

    const progressPct = Math.round((user.xp / user.nextLevelXp) * 100);

    return `
        <!-- Top RPG Level Banner -->
        <div class="card" style="background: linear-gradient(135deg, rgba(10, 132, 255, 0.15), rgba(191, 90, 242, 0.15)); border-color: rgba(10, 132, 255, 0.3);">
            <div class="card-title-row">
                <span class="card-title">LEVEL ${user.level} EXECUTIVE DEVELOPER</span>
                <span class="chip purple">${user.title}</span>
            </div>
            <div style="display: flex; justify-content: space-between; align-items: flex-end;">
                <div>
                    <div style="font-size: 32px; font-weight: 800; color: white;">${user.xp.toLocaleString()} <span style="font-size: 14px; color: var(--text-secondary);">/ ${user.nextLevelXp.toLocaleString()} XP</span></div>
                    <div style="font-size: 12px; color: var(--text-secondary); margin-top: 2px;">XP earned through code commits, completed missions, and financial audits.</div>
                </div>
                <button class="btn-header primary" onclick="window.aosStorage.addXP(100); window.aosApp.refresh();">+100 XP (Audit)</button>
            </div>
            <div class="progress-container" style="margin-top: 8px;">
                <div class="progress-fill" style="width: ${progressPct}%;"></div>
            </div>
        </div>

        <!-- RPG Attributes Grid -->
        <div class="grid-4">
            <div class="stat-box">
                <div class="icon">🧠</div>
                <div class="val">LVL ${user.stats.intellect}</div>
                <div class="lbl">INTELLECT (SYSTEM DESIGN)</div>
            </div>
            <div class="stat-box">
                <div class="icon">⚡</div>
                <div class="val">LVL ${user.stats.strength}</div>
                <div class="lbl">STRENGTH (EXECUTION SPEED)</div>
            </div>
            <div class="stat-box">
                <div class="icon">⭐</div>
                <div class="val">LVL ${user.stats.charisma}</div>
                <div class="lbl">CHARISMA (LEADERSHIP)</div>
            </div>
            <div class="stat-box">
                <div class="icon">🛡️</div>
                <div class="val">LVL ${user.stats.fortitude}</div>
                <div class="lbl">FORTITUDE (RUNWAY & RISKS)</div>
            </div>
        </div>

        <!-- Daily Quests & Missions -->
        <div class="card">
            <div class="card-title-row">
                <span class="card-title">ACTIVE EXECUTIVE MISSIONS</span>
                <span class="chip blue">${missions.filter(m => m.done).length} / ${missions.length} COMPLETED</span>
            </div>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                ${missionsHtml}
            </div>
        </div>
    `;
}

window.renderConsoleModule = renderConsoleModule;
