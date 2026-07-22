/**
 * Module 17 — Business Builder (Growth Score, Founder Readiness, Product Roadmap)
 */

function renderBusinessModule(state) {
    const biz = state.business;

    const roadmapHtml = biz.roadmap.map(item => `
        <div class="list-row">
            <div class="check-circle ${item.status === 'completed' ? 'checked' : ''}">
                ${item.status === 'completed' ? '✓' : ''}
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700; ${item.status === 'completed' ? 'text-decoration: line-through; color: var(--text-tertiary);' : ''}">${item.title}</div>
            </div>
            <span class="chip ${item.status === 'completed' ? 'green' : item.status === 'in_progress' ? 'purple' : 'orange'}">
                ${item.status.toUpperCase()}
            </span>
        </div>
    `).join('');

    return `
        <!-- Top Venture Card -->
        <div class="card" style="background: linear-gradient(135deg, rgba(191, 90, 242, 0.15), rgba(10, 132, 255, 0.1)); border-color: rgba(191, 90, 242, 0.3);">
            <div class="card-title-row">
                <span class="card-title">PRIMARY ACTIVE VENTURE (MODULE 17)</span>
                <span class="chip green">INDIE VENTURE ACTIVE</span>
            </div>
            <div style="display: flex; justify-content: space-between; align-items: flex-end;">
                <div>
                    <h2 style="font-size: 28px; font-weight: 800;">${biz.ventureName}</h2>
                    <div style="font-size: 12px; color: var(--text-secondary); margin-top: 2px;">Target Audience: ${biz.targetMarket}</div>
                </div>
                <div style="text-align: right;">
                    <div style="font-size: 32px; font-weight: 800; color: var(--accent-purple);">${biz.growthScore}%</div>
                    <div style="font-size: 10px; font-weight: 800; color: var(--text-secondary);">STARTUP GROWTH SCORE</div>
                </div>
            </div>
            <div class="progress-container">
                <div class="progress-fill" style="width: ${biz.growthScore}%; background: var(--accent-purple);"></div>
            </div>
        </div>

        <!-- Founder Metrics Breakdown -->
        <div class="grid-2">
            <div class="stat-box">
                <div class="icon">🚀</div>
                <div class="val">${biz.founderReadiness}%</div>
                <div class="lbl">FOUNDER READINESS INDEX</div>
            </div>
            <div class="stat-box">
                <div class="icon">⚡</div>
                <div class="val">${biz.executionSpeed}%</div>
                <div class="lbl">EXECUTION & DEPLOYMENT SPEED</div>
            </div>
        </div>

        <!-- Product Roadmap -->
        <div class="card">
            <span class="card-title">PRODUCT BUILDING ROADMAP & MILESTONES</span>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                ${roadmapHtml}
            </div>
        </div>
    `;
}

window.renderBusinessModule = renderBusinessModule;
