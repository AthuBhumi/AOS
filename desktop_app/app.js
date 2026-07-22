/**
 * Main ATHARVA OS App Controller & Router
 */

class ATHARVA_App {
    constructor() {
        this.currentTab = 'console';
        this.aiOpen = false;
        this.init();
    }

    init() {
        this.refresh();
    }

    setTab(tabName) {
        this.currentTab = tabName;

        // Update nav buttons
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.toggle('active', link.dataset.tab === tabName);
        });

        // Update Titles
        const meta = {
            console: { title: 'Executive Command Console', sub: 'Module 01 • Developer Operating System & RPG Stats' },
            ceo: { title: 'CEO Command Center', sub: 'Module 19 • Executive Performance Ring & Decision Engine' },
            business: { title: 'Business Builder', sub: 'Module 17 • Startup Growth Score & Product Roadmap' },
            company: { title: 'Company Builder', sub: 'Module 18 • Health Score, CRM Pipeline & Department Teams' },
            finance: { title: 'Capital & Finance Engine', sub: 'Module 16 • Net Worth, Runway Gauge & Transaction Ledger' },
            routines: { title: 'Routines & Productivity', sub: 'Modules 05/08 • Atomic Habits, Streaks & OKR Goals' },
            coding: { title: 'Coding Sandbox & Practice', sub: 'Module 09 • Algorithm Drills & Live Code Runner' },
            journal: { title: 'Journal & Knowledge Base', sub: 'Modules 07/10 • Reflection Logs & Reading List' }
        };

        const currentMeta = meta[tabName] || meta.console;
        document.getElementById('view-title').innerText = currentMeta.title;
        document.getElementById('view-subtitle').innerText = currentMeta.sub;

        this.refresh();
    }

    refresh() {
        const state = window.aosStorage.state;
        const viewport = document.getElementById('viewport');

        if (this.currentTab === 'console' && window.renderConsoleModule) {
            viewport.innerHTML = window.renderConsoleModule(state);
        } else if (this.currentTab === 'ceo' && window.renderCEOModule) {
            viewport.innerHTML = window.renderCEOModule(state);
        } else if (this.currentTab === 'business' && window.renderBusinessModule) {
            viewport.innerHTML = window.renderBusinessModule(state);
        } else if (this.currentTab === 'company' && window.renderCompanyModule) {
            viewport.innerHTML = window.renderCompanyModule(state);
        } else if (this.currentTab === 'finance' && window.renderFinanceModule) {
            viewport.innerHTML = window.renderFinanceModule(state);
        } else if (this.currentTab === 'routines' && window.renderRoutinesModule) {
            viewport.innerHTML = window.renderRoutinesModule(state);
        } else if (this.currentTab === 'coding' && window.renderCodingModule) {
            viewport.innerHTML = window.renderCodingModule(state);
        } else if (this.currentTab === 'journal' && window.renderJournalModule) {
            viewport.innerHTML = window.renderJournalModule(state);
        }
    }

    toggleAI() {
        this.aiOpen = !this.aiOpen;
        const modal = document.getElementById('ai-modal');
        if (this.aiOpen) {
            modal.classList.add('open');
        } else {
            modal.classList.remove('open');
        }
    }

    sendAIMsg() {
        const input = document.getElementById('ai-input');
        const text = input.value.trim();
        if (!text) return;

        const body = document.getElementById('ai-chat-body');
        body.innerHTML += `<div class="chat-msg user">${text}</div>`;
        input.value = '';
        body.scrollTop = body.scrollHeight;

        setTimeout(() => {
            const state = window.aosStorage.state;
            let aiReply = `AI Mentor: Analyzing query "${text}". All 19 ATHARVA OS modules are synchronized. Current Runway is ${state.finance.runwayMonths} months and Growth Score is ${state.business.growthScore}%.`;
            if (text.toLowerCase().includes('runway') || text.toLowerCase().includes('finance')) {
                aiReply = `AI Mentor: Your current Net Worth is $${state.finance.netWorth.toLocaleString()} with ${state.finance.runwayMonths} months of cash runway. Recommend keeping monthly burn under $2,000.`;
            } else if (text.toLowerCase().includes('hire') || text.toLowerCase().includes('decision')) {
                aiReply = `AI Mentor: You have ${state.ceo.decisions.filter(d => d.status === 'pending').length} pending executive decisions. Reallocating budget to cloud infra will increase system velocity by 18%.`;
            }
            body.innerHTML += `<div class="chat-msg assistant">${aiReply}</div>`;
            body.scrollTop = body.scrollHeight;
        }, 500);
    }
}

window.aosApp = new ATHARVA_App();
