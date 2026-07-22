/**
 * Module 19 — CEO Command Center (Performance Ring, Strategic KPIs, Decision Engine)
 */

function renderCEOModule(state) {
    const ceo = state.ceo;
    const pendingDecisions = ceo.decisions.filter(d => d.status === 'pending');

    const decisionRowsHtml = ceo.decisions.map(d => `
        <div class="list-row" style="flex-direction: column; align-items: flex-start; gap: 8px;">
            <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                <span class="chip ${d.impact === 'Critical' ? 'orange' : d.impact === 'High' ? 'blue' : 'purple'}">${d.impact.toUpperCase()} IMPACT • ${d.category}</span>
                <span style="font-size: 11px; font-weight: 700; color: ${d.status === 'approved' ? 'var(--accent-green)' : d.status === 'deferred' ? 'var(--accent-red)' : 'var(--accent-orange)'};">
                    ${d.status.toUpperCase()}
                </span>
            </div>
            <div style="font-size: 13px; font-weight: 700;">${d.title}</div>
            ${d.status === 'pending' ? `
                <div style="display: flex; gap: 8px; width: 100%; margin-top: 4px;">
                    <button class="btn-header primary" style="flex: 1; height: 32px; font-size: 12px;" onclick="window.aosStorage.resolveDecision('${d.id}', 'approved'); window.aosApp.refresh();">Approve</button>
                    <button class="btn-header" style="flex: 1; height: 32px; font-size: 12px;" onclick="window.aosStorage.resolveDecision('${d.id}', 'deferred'); window.aosApp.refresh();">Defer</button>
                </div>
            ` : ''}
        </div>
    `).join('');

    // Calculate ring SVG offset
    const ringOffset = Math.round(377 - (377 * (ceo.overallScore / 100)));

    return `
        <!-- Top CEO Performance Gauge -->
        <div class="card" style="background: linear-gradient(180deg, rgba(191, 90, 242, 0.1), var(--card-bg)); align-items: center; text-align: center;">
            <span class="card-title">OVERALL EXECUTIVE PERFORMANCE RING (MODULE 19)</span>
            <div class="performance-ring-container">
                <div class="ring-outer">
                    <svg width="140" height="140" class="ring-svg">
                        <circle cx="70" cy="70" r="60" class="ring-bg"></circle>
                        <circle cx="70" cy="70" r="60" class="ring-val" stroke-dasharray="377" stroke-dashoffset="${ringOffset}"></circle>
                    </svg>
                    <div class="ring-text">
                        <span class="ring-number">${ceo.overallScore}%</span>
                        <span class="ring-label">SCORE</span>
                    </div>
                </div>
            </div>
            <div style="font-size: 12px; color: var(--accent-green); font-weight: 700;">● EXECUTIVE STATUS OPTIMAL</div>
        </div>

        <!-- Strategic CEO KPIs Grid -->
        <div class="grid-4">
            <div class="stat-box" style="border-color: rgba(191, 90, 242, 0.3);">
                <div class="lbl">FOUNDER READINESS</div>
                <div class="val" style="color: var(--accent-purple);">${ceo.kpis.founderReadiness}%</div>
            </div>
            <div class="stat-box" style="border-color: rgba(10, 132, 255, 0.3);">
                <div class="lbl">EXECUTION RATE</div>
                <div class="val" style="color: var(--accent-blue);">${ceo.kpis.executionRate}%</div>
            </div>
            <div class="stat-box" style="border-color: rgba(255, 159, 10, 0.3);">
                <div class="lbl">LEADERSHIP SCORE</div>
                <div class="val" style="color: var(--accent-orange);">${ceo.kpis.leadership}%</div>
            </div>
            <div class="stat-box" style="border-color: rgba(48, 209, 88, 0.3);">
                <div class="lbl">LIFE BALANCE INDEX</div>
                <div class="val" style="color: var(--accent-green);">${ceo.kpis.lifeBalance}%</div>
            </div>
        </div>

        <!-- High Priority Decision Engine -->
        <div class="card">
            <div class="card-title-row">
                <span class="card-title">HIGH-PRIORITY EXECUTIVE DECISION ENGINE</span>
                <span class="chip orange">${pendingDecisions.length} PENDING DECISIONS</span>
            </div>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                ${decisionRowsHtml}
            </div>
        </div>
    `;
}

window.renderCEOModule = renderCEOModule;
