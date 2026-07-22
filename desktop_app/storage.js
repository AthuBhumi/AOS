/**
 * ATHARVA OS — Local Data Storage & Persistence Manager
 * Uses LocalStorage with fallback and default demo seeding
 */

const STORAGE_KEY = 'ATHARVA_OS_STATE_V1';

const DEFAULT_STATE = {
    user: {
        name: 'Atharva',
        title: 'Founder & CEO',
        level: 7,
        xp: 2450,
        nextLevelXp: 3000,
        stats: {
            intellect: 4,
            strength: 3,
            charisma: 5,
            fortitude: 4
        }
    },
    missions: [
        { id: 'm1', title: 'Complete 1 LeetCode Hard Problem', xp: 75, done: true, category: 'Coding' },
        { id: 'm2', title: 'Review Monthly Cash Burn & Runway', xp: 50, done: false, category: 'Finance' },
        { id: 'm3', title: 'Log 30 min Typing Drill (Goal: 85 WPM)', xp: 40, done: false, category: 'Skills' },
        { id: 'm4', title: 'Execute CEO Quarterly Strategic Review', xp: 100, done: false, category: 'Leadership' }
    ],
    finance: {
        netWorth: 67850,
        cashReserves: 15500,
        monthlyBurn: 1850,
        monthlyIncome: 4500,
        runwayMonths: 8.4,
        transactions: [
            { id: 't1', title: 'SaaS Client Retainer', amount: 4500, type: 'income', category: 'Revenue', date: '2026-07-20' },
            { id: 't2', title: 'Co-Working Desk Office', amount: 1500, type: 'expense', category: 'Fixed', date: '2026-07-18' },
            { id: 't3', title: 'AWS Cloud Infrastructure', amount: 350, type: 'expense', category: 'Variable', date: '2026-07-15' },
            { id: 't4', title: 'Stripe Payment Fees', amount: 85, type: 'expense', category: 'Variable', date: '2026-07-12' }
        ],
        savingsGoals: [
            { id: 'sg1', name: 'Emergency Runway Fund', target: 25000, current: 15500, color: '#0A84FF' },
            { id: 'sg2', name: 'Cloud Infra Buffer', target: 5000, current: 3200, color: '#BF5AF2' }
        ]
    },
    business: {
        growthScore: 72.5,
        founderReadiness: 68.0,
        executionSpeed: 75.0,
        ventureName: 'ATHARVA OS',
        targetMarket: 'Indie Hackers & Senior Engineers',
        roadmap: [
            { id: 'r1', title: 'SwiftData & SQLCipher Architecture', status: 'completed' },
            { id: 'r2', title: 'Standalone Windows & Web Engine', status: 'completed' },
            { id: 'r3', title: 'AI Mentor Prompt Engineering v2', status: 'in_progress' },
            { id: 'r4', title: 'Public Product Hunt Launch', status: 'planned' }
        ]
    },
    company: {
        healthScore: 59.0,
        profitMargin: 78.2,
        crmLeads: [
            { id: 'c1', name: 'Acme Software Corp', value: 12000, stage: 'Negotiation', contact: 'John Doe' },
            { id: 'c2', name: 'DevStudio Labs', value: 8500, stage: 'Proposal Sent', contact: 'Sarah Smith' },
            { id: 'c3', name: 'CloudScale Inc', value: 25000, stage: 'Discovery', contact: 'Alex Rivera' }
        ],
        departments: [
            { id: 'd1', name: 'Engineering', lead: 'Atharva (CEO)', headcount: 4 },
            { id: 'd2', name: 'Product & Design', lead: 'Atharva (CEO)', headcount: 2 },
            { id: 'd3', name: 'Growth & Sales', lead: 'Atharva (CEO)', headcount: 1 }
        ]
    },
    ceo: {
        overallScore: 68,
        kpis: {
            founderReadiness: 72.5,
            executionRate: 65.0,
            leadership: 70.8,
            lifeBalance: 80.0
        },
        decisions: [
            { id: 'd1', title: 'Reallocate $1,000 budget to Cloud Infrastructure', category: 'Finance', status: 'pending', impact: 'High' },
            { id: 'd2', title: 'Hire Part-time Frontend Developer for Module UI', category: 'Hiring', status: 'pending', impact: 'Medium' },
            { id: 'd3', title: 'Shift from B2C to Founder Executive B2B Model', category: 'Strategy', status: 'approved', impact: 'Critical' }
        ]
    },
    habits: [
        { id: 'h1', name: 'Morning Meditation', streak: 14, category: 'Mindfulness', doneToday: true },
        { id: 'h2', name: 'Read 30 Pages of Architecture Book', streak: 8, category: 'Learning', doneToday: false },
        { id: 'h3', name: 'Gym & Strength Workout', streak: 5, category: 'Health', doneToday: true },
        { id: 'h4', name: 'Deep Work Code Sprint (2 Hours)', streak: 21, category: 'Execution', doneToday: true }
    ],
    goals: [
        { id: 'g1', title: 'Ship ATHARVA OS v1.0 Production Release', progress: 85, category: 'Product' },
        { id: 'g2', title: 'Reach $10k Monthly Recurring Revenue', progress: 45, category: 'Revenue' },
        { id: 'g3', title: 'Master Distributed Systems Design', progress: 70, category: 'Skills' }
    ],
    journal: [
        { id: 'j1', title: 'Engineered Full Windows OS Platform', mood: '🔥', content: 'Successfully created the Windows desktop architecture for ATHARVA OS with local data state.', date: '2026-07-22' },
        { id: 'j2', title: 'Refactored Core Module Schemas', mood: '💡', content: 'Cleaned up model dependencies and improved execution speed.', date: '2026-07-21' }
    ],
    coding: [
        { id: 'cp1', title: 'LRU Cache Design & Implementation', difficulty: 'Medium', solved: true, language: 'JavaScript / C++' },
        { id: 'cp2', title: 'Concurrent Financial Ledger Engine', difficulty: 'Hard', solved: true, language: 'Swift / Rust' },
        { id: 'cp3', title: 'Graph Shortest Path Navigator', difficulty: 'Medium', solved: false, language: 'Python' }
    ],
    reading: [
        { id: 'b1', title: 'Designing Data-Intensive Applications', author: 'Martin Kleppmann', progress: 340, totalPages: 560, status: 'reading' },
        { id: 'b2', title: 'Atomic Habits', author: 'James Clear', progress: 320, totalPages: 320, status: 'completed' },
        { id: 'b3', title: 'Zero to One', author: 'Peter Thiel', progress: 140, totalPages: 224, status: 'reading' }
    ]
};

class AOSStorage {
    constructor() {
        this.state = this.loadState();
    }

    loadState() {
        try {
            const raw = localStorage.getItem(STORAGE_KEY);
            if (raw) {
                return JSON.parse(raw);
            }
        } catch (e) {
            console.warn('LocalStorage load failed, using default state:', e);
        }
        return JSON.parse(JSON.stringify(DEFAULT_STATE));
    }

    saveState() {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state));
        } catch (e) {
            console.error('Failed to save state:', e);
        }
    }

    resetState() {
        this.state = JSON.parse(JSON.stringify(DEFAULT_STATE));
        this.saveState();
        return this.state;
    }

    // User & XP Mutators
    addXP(amount) {
        this.state.user.xp += amount;
        if (this.state.user.xp >= this.state.user.nextLevelXp) {
            this.state.user.level += 1;
            this.state.user.nextLevelXp += 1000;
        }
        this.saveState();
        return this.state.user;
    }

    toggleMission(id) {
        const mission = this.state.missions.find(m => m.id === id);
        if (mission) {
            mission.done = !mission.done;
            if (mission.done) {
                this.addXP(mission.xp);
            }
            this.saveState();
        }
        return this.state.missions;
    }

    // Habit Mutator
    toggleHabit(id) {
        const habit = this.state.habits.find(h => h.id === id);
        if (habit) {
            habit.doneToday = !habit.doneToday;
            if (habit.doneToday) {
                habit.streak += 1;
                this.addXP(25);
            } else {
                habit.streak = Math.max(0, habit.streak - 1);
            }
            this.saveState();
        }
        return this.state.habits;
    }

    // Transaction Mutator
    addTransaction(tx) {
        tx.id = 't_' + Date.now();
        this.state.finance.transactions.unshift(tx);
        if (tx.type === 'income') {
            this.state.finance.netWorth += tx.amount;
            this.state.finance.cashReserves += tx.amount;
        } else {
            this.state.finance.netWorth -= tx.amount;
            this.state.finance.cashReserves -= tx.amount;
        }
        // Recalculate runway
        if (this.state.finance.monthlyBurn > 0) {
            this.state.finance.runwayMonths = Number((this.state.finance.cashReserves / this.state.finance.monthlyBurn).toFixed(1));
        }
        this.saveState();
        return this.state.finance;
    }

    // CEO Decision Mutator
    resolveDecision(id, action) {
        const dec = this.state.ceo.decisions.find(d => d.id === id);
        if (dec) {
            dec.status = action; // 'approved' or 'deferred'
            this.addXP(50);
            this.saveState();
        }
        return this.state.ceo.decisions;
    }
}

window.aosStorage = new AOSStorage();
