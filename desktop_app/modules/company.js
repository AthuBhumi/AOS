/**
 * Module 18 — Company Builder (Company Health Index, CRM Leads, Departments)
 */

function renderCompanyModule(state) {
    const comp = state.company;

    const crmRowsHtml = comp.crmLeads.map(lead => `
        <div class="list-row">
            <div style="width: 34px; height: 34px; border-radius: 8px; background: rgba(10, 132, 255, 0.15); display: flex; align-items: center; justify-content: center; font-weight: 700; color: var(--accent-blue);">
                🏢
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700;">${lead.name}</div>
                <div style="font-size: 11px; color: var(--text-tertiary);">${lead.contact} • ${lead.stage}</div>
            </div>
            <div style="font-size: 14px; font-weight: 800; color: var(--accent-green);">$${lead.value.toLocaleString()}</div>
        </div>
    `).join('');

    const deptRowsHtml = comp.departments.map(d => `
        <div class="list-row">
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700;">${d.name}</div>
                <div style="font-size: 11px; color: var(--text-tertiary);">Lead: ${d.lead}</div>
            </div>
            <span class="chip purple">${d.headcount} Members</span>
        </div>
    `).join('');

    return `
        <!-- Top Health Score Bar -->
        <div class="grid-2">
            <div class="card" style="border-color: rgba(48, 209, 88, 0.3);">
                <span class="card-title">COMPANY HEALTH INDEX (MODULE 18)</span>
                <div style="font-size: 34px; font-weight: 800; color: var(--accent-green);">${comp.healthScore}%</div>
                <div style="font-size: 11px; color: var(--text-secondary);">Calculated from cashflow stability, team velocity, & sales pipeline.</div>
            </div>

            <div class="card" style="border-color: rgba(10, 132, 255, 0.3);">
                <span class="card-title">NET PROFIT MARGIN</span>
                <div style="font-size: 34px; font-weight: 800; color: var(--accent-blue);">${comp.profitMargin}%</div>
                <div style="font-size: 11px; color: var(--text-secondary);">High efficiency bootstrap financial structure.</div>
            </div>
        </div>

        <!-- CRM & Leads Pipeline -->
        <div class="grid-2">
            <div class="card">
                <span class="card-title">CRM & CLIENT PIPELINE</span>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${crmRowsHtml}
                </div>
            </div>

            <div class="card">
                <span class="card-title">DEPARTMENTS & TEAMS</span>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${deptRowsHtml}
                </div>
            </div>
        </div>
    `;
}

window.renderCompanyModule = renderCompanyModule;
