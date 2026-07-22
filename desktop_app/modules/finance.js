/**
 * Module 16 — Finance Engine (Capital, Net Worth, Runway Gauge, Transactions)
 */

function renderFinanceModule(state) {
    const fin = state.finance;

    const txRowsHtml = fin.transactions.map(t => `
        <div class="list-row">
            <div style="width: 36px; height: 36px; border-radius: 10px; background: ${t.type === 'income' ? 'rgba(48, 209, 88, 0.15)' : 'rgba(255, 255, 255, 0.05)'}; display: flex; align-items: center; justify-content: center; font-size: 16px;">
                ${t.type === 'income' ? '📈' : '💳'}
            </div>
            <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 700;">${t.title}</div>
                <div style="font-size: 11px; color: var(--text-tertiary);">${t.category} • ${t.date}</div>
            </div>
            <div style="font-size: 14px; font-weight: 800; color: ${t.type === 'income' ? 'var(--accent-green)' : 'var(--text-primary)'};">
                ${t.type === 'income' ? '+' : '-'}$${t.amount.toLocaleString()}
            </div>
        </div>
    `).join('');

    const savingsGoalsHtml = fin.savingsGoals.map(sg => {
        const pct = Math.min(100, Math.round((sg.current / sg.target) * 100));
        return `
            <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-line); padding: 14px; border-radius: 14px;">
                <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 6px;">
                    <span>${sg.name}</span>
                    <span style="color: ${sg.color};">$${sg.current.toLocaleString()} / $${sg.target.toLocaleString()}</span>
                </div>
                <div class="progress-container">
                    <div class="progress-fill" style="width: ${pct}%; background: ${sg.color};"></div>
                </div>
            </div>
        `;
    }).join('');

    return `
        <!-- Top Financial Overview -->
        <div class="grid-3">
            <div class="card" style="border-color: rgba(48, 209, 88, 0.3);">
                <span class="card-title">TOTAL NET WORTH</span>
                <div style="font-size: 32px; font-weight: 800; color: white;">$${fin.netWorth.toLocaleString()}</div>
                <div style="font-size: 11px; color: var(--accent-green); font-weight: 700;">+12.4% vs Previous Month</div>
            </div>

            <div class="card" style="border-color: rgba(10, 132, 255, 0.3);">
                <span class="card-title">CASH RESERVES</span>
                <div style="font-size: 32px; font-weight: 800; color: var(--accent-blue);">$${fin.cashReserves.toLocaleString()}</div>
                <div style="font-size: 11px; color: var(--text-secondary);">Liquid Capital Available</div>
            </div>

            <div class="card" style="border-color: rgba(191, 90, 242, 0.3);">
                <span class="card-title">CASH RUNWAY ENGINE</span>
                <div style="font-size: 32px; font-weight: 800; color: var(--accent-purple);">${fin.runwayMonths} <span style="font-size: 14px; color: var(--text-secondary);">Months</span></div>
                <div style="font-size: 11px; color: var(--text-secondary);">Based on $${fin.monthlyBurn.toLocaleString()}/mo burn rate</div>
            </div>
        </div>

        <!-- Quick Add Transaction Bar -->
        <div class="card">
            <div class="card-title-row">
                <span class="card-title">LOG NEW FINANCIAL TRANSACTION</span>
            </div>
            <div style="display: flex; gap: 10px;">
                <input type="text" id="tx-title" placeholder="Transaction title (e.g. Client Payment)" style="flex: 2; background: rgba(255,255,255,0.05); border: 1px solid var(--border-line); border-radius: 10px; padding: 10px; color: white; font-size: 13px;">
                <input type="number" id="tx-amount" placeholder="Amount ($)" style="flex: 1; background: rgba(255,255,255,0.05); border: 1px solid var(--border-line); border-radius: 10px; padding: 10px; color: white; font-size: 13px;">
                <select id="tx-type" style="background: rgba(255,255,255,0.05); border: 1px solid var(--border-line); border-radius: 10px; padding: 10px; color: white; font-size: 13px;">
                    <option value="income">Income (+)</option>
                    <option value="expense">Expense (-)</option>
                </select>
                <button class="btn-header primary" onclick="
                    const title = document.getElementById('tx-title').value;
                    const amount = parseFloat(document.getElementById('tx-amount').value);
                    const type = document.getElementById('tx-type').value;
                    if(title && amount) {
                        window.aosStorage.addTransaction({ title, amount, type, category: 'General', date: new Date().toISOString().split('T')[0] });
                        window.aosApp.refresh();
                    }
                ">Log Transaction</button>
            </div>
        </div>

        <!-- Two Columns: Ledger + Savings -->
        <div class="grid-2">
            <div class="card">
                <span class="card-title">TRANSACTION LEDGER</span>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${txRowsHtml}
                </div>
            </div>

            <div class="card">
                <span class="card-title">CAPITAL RESERVES & SAVINGS GOALS</span>
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    ${savingsGoalsHtml}
                </div>
            </div>
        </div>
    `;
}

window.renderFinanceModule = renderFinanceModule;
