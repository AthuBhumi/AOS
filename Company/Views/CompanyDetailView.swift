import SwiftUI
import Models

public struct CompanyDetailView: View {
    @Bindable private var viewModel: CompanyBuilderViewModel
    let company: Company
    private let userId: UUID
    
    @State private var selectedTab = 0
    @State private var aiAdvisorVM = AICompanyAdvisorViewModel()
    
    // Form inputs
    @State private var empName = ""
    @State private var empRole = ""
    @State private var empDept = "Engineering"
    @State private var empSalary = ""
    
    @State private var taskTitle = ""
    @State private var taskStatus = "To Do"
    
    @State private var clientName = ""
    @State private var invoiceAmount = ""
    
    public init(viewModel: CompanyBuilderViewModel, company: Company, userId: UUID) {
        self.viewModel = viewModel
        self.company = company
        self.userId = userId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tab Segment Selector
            Picker("", selection: $selectedTab) {
                Text("Roster").tag(0)
                Text("Sprints").tag(1)
                Text("Billing").tag(2)
                Text("SOPs").tag(3)
                Text("AI").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.black)
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case 0:
                            rosterTab()
                        case 1:
                            sprintsTab()
                        case 2:
                            billingTab()
                        case 3:
                            sopsTab()
                        default:
                            aiReportsTab()
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Tab Layouts
    private func rosterTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Employee Roster & Payroll")
            
            // Add Employee Form Card
            VStack(spacing: 12) {
                TextField("", text: $empName, prompt: Text("Full Name").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    TextField("", text: $empRole, prompt: Text("Role (e.g. Architect)").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $empSalary, prompt: Text("Salary / mo").foregroundColor(.gray))
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                
                Picker("", selection: $empDept) {
                    Text("Engineering").tag("Engineering")
                    Text("Marketing").tag("Marketing")
                    Text("Sales").tag("Sales")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button("Hire Employee") {
                    if let sal = Double(empSalary) {
                        let emp = Employee(name: empName, role: empRole, department: empDept, salary: sal, company: company)
                        company.employees.append(emp)
                        company.expenses += sal // Adds salary to corporate monthly expenses ledger
                        viewModel.commitCompanyDetails(company: company, forUser: userId)
                        empName = ""
                        empRole = ""
                        empSalary = ""
                    }
                }
                .disabled(empName.isEmpty || empSalary.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            
            // Employees list
            VStack(spacing: 10) {
                ForEach(company.employees) { emp in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(emp.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(emp.role) • \(emp.department)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "$%.0f/mo", emp.salary))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            // Log attendance button
                            Button(action: {
                                emp.attendanceDays = min(20, emp.attendanceDays + 1)
                                viewModel.commitCompanyDetails(company: company, forUser: userId)
                            }) {
                                Text("Log Attendance (\(emp.attendanceDays)/20)")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "#30D158").opacity(0.15))
                                    .foregroundColor(Color(hex: "#30D158"))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func sprintsTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Sprint Kanban Board")
            
            // Add Task Form Card
            VStack(spacing: 12) {
                TextField("", text: $taskTitle, prompt: Text("Task summary...").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                Picker("", selection: $taskStatus) {
                    Text("To Do").tag("To Do")
                    Text("In Progress").tag("In Progress")
                    Text("Done").tag("Done")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button("Assign Task") {
                    let task = CompanyProject(title: taskTitle, status: taskStatus, company: company)
                    company.projects.append(task)
                    viewModel.commitCompanyDetails(company: company, forUser: userId)
                    taskTitle = ""
                }
                .disabled(taskTitle.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            
            // Kanban rows
            VStack(spacing: 10) {
                ForEach(company.projects) { project in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(project.title)
                                .foregroundColor(.white)
                                .strikethrough(project.status == "Done")
                            
                            HStack {
                                Text(project.status)
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(statusColor(project.status).opacity(0.2))
                                    .foregroundColor(statusColor(project.status))
                                    .cornerRadius(4)
                            }
                        }
                        Spacer()
                        
                        // Toggle Status Actions
                        HStack(spacing: 6) {
                            Button("ToDo") { viewModel.updateProjectStatus(companyId: company.id, projectId: project.id, status: "To Do", forUser: userId) }
                                .font(.system(size: 10))
                            Button("Prog") { viewModel.updateProjectStatus(companyId: company.id, projectId: project.id, status: "In Progress", forUser: userId) }
                                .font(.system(size: 10))
                            Button("Done") { viewModel.updateProjectStatus(companyId: company.id, projectId: project.id, status: "Done", forUser: userId) }
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color(hex: "#0A84FF"))
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func billingTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Client Billings (CRM)")
            
            // Add Invoice Form
            VStack(spacing: 12) {
                TextField("", text: $clientName, prompt: Text("Client Company Name").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                TextField("", text: $invoiceAmount, prompt: Text("Invoice Amount ($)").foregroundColor(.gray))
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                Button("Generate Invoice") {
                    if let value = Double(invoiceAmount) {
                        let inv = Invoice(clientName: clientName, amount: value, company: company)
                        company.invoices.append(inv)
                        viewModel.commitCompanyDetails(company: company, forUser: userId)
                        clientName = ""
                        invoiceAmount = ""
                    }
                }
                .disabled(clientName.isEmpty || invoiceAmount.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            
            // Invoices lists
            VStack(spacing: 10) {
                ForEach(company.invoices) { inv in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(inv.clientName)
                                .foregroundColor(.white)
                            Text(String(format: "$%.2f", inv.amount))
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleInvoicePayment(companyId: company.id, invoiceId: inv.id, forUser: userId)
                        }) {
                            Text(inv.isPaid ? "Paid" : "Mark Paid")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(inv.isPaid ? Color(hex: "#30D158").opacity(0.15) : Color(hex: "#FF453A").opacity(0.15))
                                .foregroundColor(inv.isPaid ? Color(hex: "#30D158") : Color(hex: "#FF453A"))
                                .cornerRadius(6)
                        }
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func sopsTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Company Policies & Knowledge SOPs")
            
            ForEach(company.sops) { sop in
                VStack(alignment: .leading, spacing: 8) {
                    Text(sop.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(sop.policyText)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#1C1C1E").opacity(0.7))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func aiReportsTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("AI Corporate Advisor")
            
            Button("Compile Weekly Executive Report") {
                aiAdvisorVM.compileWeeklyManagementReport(
                    forCompany: company,
                    healthScore: viewModel.getCompanyHealthScore(forCompany: company),
                    progress: viewModel.getProjectProgress(forCompany: company),
                    profitMargin: viewModel.getProfitMargin(forCompany: company)
                )
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#30D158"))
            .foregroundColor(.black)
            .cornerRadius(12)
            
            if !aiAdvisorVM.weeklyReportText.isEmpty {
                Text(aiAdvisorVM.weeklyReportText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sub Helpers
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
            Spacer()
        }
        .padding(.top, 12)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Done": return Color(hex: "#30D158")
        case "In Progress": return Color(hex: "#FFD60A")
        default: return Color(hex: "#0A84FF")
        }
    }
}
extension Employee: Identifiable {}
extension CompanyProject: Identifiable {}
extension Invoice: Identifiable {}
extension SOP: Identifiable {}
