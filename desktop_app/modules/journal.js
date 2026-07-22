/**
 * Module 07 & 10 — Developer Journal & Reading Knowledge Base
 */

function renderJournalModule(state) {
    const journal = state.journal;
    const reading = state.reading;

    const jHtml = journal.map(j => `
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-line); padding: 14px; border-radius: 14px; margin-bottom: 8px;">
            <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 4px;">
                <span>${j.mood} ${j.title}</span>
                <span style="font-size: 11px; color: var(--text-tertiary);">${j.date}</span>
            </div>
            <div style="font-size: 12px; color: var(--text-secondary); line-height: 1.5;">${j.content}</div>
        </div>
    `).join('');

    const rHtml = reading.map(b => {
        const pct = Math.round((b.progress / b.totalPages) * 100);
        return `
            <div class="list-row">
                <div style="font-size: 20px;">📖</div>
                <div style="flex: 1;">
                    <div style="font-size: 13px; font-weight: 700;">${b.title}</div>
                    <div style="font-size: 11px; color: var(--text-tertiary);">${b.author} • ${b.progress}/${b.totalPages} pages (${pct}%)</div>
                </div>
                <span class="chip ${pct === 100 ? 'green' : 'blue'}">${pct === 100 ? 'FINISHED' : 'READING'}</span>
            </div>
        `;
    }).join('');

    return `
        <div class="grid-2">
            <div class="card">
                <span class="card-title">DEVELOPER JOURNAL & REFLECTION (MODULE 07)</span>
                <div>${jHtml}</div>
            </div>

            <div class="card">
                <span class="card-title">READING LIST & KNOWLEDGE BASE (MODULE 10)</span>
                <div style="display: flex; flex-direction: column; gap: 8px;">${rHtml}</div>
            </div>
        </div>
    `;
}

window.renderJournalModule = renderJournalModule;
