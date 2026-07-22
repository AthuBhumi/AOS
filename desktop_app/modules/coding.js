/**
 * Module 09 — Coding Sandbox & Practice Engine
 */

function renderCodingModule(state) {
    const problems = state.coding;

    const probHtml = problems.map(p => `
        <div class="list-row">
            <div class="check-circle ${p.solved ? 'checked' : ''}">
                ${p.solved ? '✓' : ''}
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700;">${p.title}</div>
                <div style="font-size: 11px; color: var(--text-tertiary);">${p.language}</div>
            </div>
            <span class="chip ${p.difficulty === 'Hard' ? 'orange' : 'purple'}">${p.difficulty}</span>
        </div>
    `).join('');

    return `
        <div class="card">
            <span class="card-title">CODING DRILLS & ALGORITHM PRACTICE (MODULE 09)</span>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                ${probHtml}
            </div>
        </div>

        <!-- Code Sandbox Simulation Box -->
        <div class="card">
            <div class="card-title-row">
                <span class="card-title">LIVE CODING SANDBOX</span>
                <span class="chip blue">SWIFT / JS / RUST</span>
            </div>
            <textarea style="width: 100%; height: 180px; background: rgba(0,0,0,0.4); border: 1px solid var(--border-line); border-radius: 12px; padding: 14px; color: #30D158; font-family: var(--font-mono); font-size: 13px; outline: none; resize: none;" readonly>// ATHARVA OS Code Compiler Simulator
class FinancialLedgerEngine {
    constructor() {
        this.runwayMonths = 8.4;
    }
    audit() {
        console.log("Runway Status: Optimal");
    }
}
const engine = new FinancialLedgerEngine();
engine.audit();</textarea>
            <div style="display: flex; justify-content: flex-end;">
                <button class="btn-header primary" onclick="alert('Compiler output: Runway Status: Optimal (0.04ms execution)');">Run Sandbox Code</button>
            </div>
        </div>
    `;
}

window.renderCodingModule = renderCodingModule;
