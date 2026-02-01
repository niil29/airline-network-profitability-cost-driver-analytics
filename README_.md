# ✈️ Airline Network Profitability & Cost Driver Analytics

## 📌 Project Overview
This project analyzes airline profitability at a **network level**, focusing on how **routes, carriers, distance bands, and cost drivers** influence overall financial performance.  
It combines **SQL-based data modeling** with **Power BI analytics** to deliver decision-oriented insights rather than static reporting.

The project is designed to reflect **real-world analytical trade-offs**, including working without flight-level granularity and using proxy-based cost allocation.

---

## 🎯 Business Problem
Airline networks often appear profitable in aggregate, while concealing:
- Heavy profit concentration across a small set of routes
- Loss-making or marginal routes hidden by averages
- Cost inefficiencies varying by distance band
- Dependency on a limited number of carriers

This project answers:
- Where does profit actually come from?
- Which cost drivers matter most?
- How balanced and sustainable is the route network?

---

## 🧩 Data & Modeling Assumptions
- One row represents **Carrier × Route × Month**
- No flight-level or flight-count data available
- Flight-driven costs are approximated using **passenger-based activity factors**
- Revenue and cost logic is parameterized using a finance configuration table
- Emphasis is placed on **behavioral realism** rather than synthetic precision

---

## 🗄️ SQL Data Modeling
The SQL layer is responsible for building a clean analytical foundation:

### Key Components
- **Staging layer** for raw airline operational data
- **Dimension tables** (Route, Carrier, Date, Geography)
- **Fact table** aggregating monthly operational metrics
- **Finance parameters table** to control revenue and cost assumptions
- **Analytical profitability view** exposing revenue, cost, and profit measures

### Core Objects
- `fact_airline_operations`
- `finance_parameters`
- `vw_airline_profitability`

All revenue and cost drivers are **fully parameterized**, enabling scenario-style analysis without rewriting logic.

---

## 📊 Power BI Analytics

The Power BI model builds on the SQL analytical view and is organized into three purpose-driven pages.

---

### 📄 Page 1 — Executive Profitability Overview
**Purpose:** Provide a high-level view of network scale, profit concentration, and risk.

**Key Elements:**
- Active Routes
- Active Carriers
- Top 20% Profit Contribution
- % Loss-Making Routes

**Insight:**  
Profitability is highly concentrated, indicating that overall positive margins mask structural fragility within the network.

---

### 📄 Page 2 — Cost Drivers & Efficiency
**Purpose:** Explain *why* costs behave the way they do and how efficiency changes across distance segments.

**Key Elements:**
- Cost composition by distance band
- Cost decomposition analysis
- Average cost per passenger by distance band

**Insight:**  
Cost efficiency improves from short- to medium-haul routes but deteriorates again for long-haul operations due to fuel, crew, and navigation costs.

---

### 📄 Page 3 — Network Performance (Routes & Carriers)
**Purpose:** Evaluate how profitability is distributed across routes and carriers.

**Key Elements:**
- Carrier-level profit concentration
- Route efficiency vs revenue scale
- Network balance and dependency indicators

**Insight:**  
Network profitability is driven more by scale and concentration than by uniform route-level efficiency.

---

## 🔑 Key Takeaways
- Airline profitability is **scale-driven and highly concentrated**
- Short-haul routes are structurally cost-heavy
- A small subset of routes and carriers dominate total profit
- Cost transparency is critical for long-term network sustainability

---

## 🛠️ Tools & Technologies
- SQL Server
- Power BI
- GitHub

---


## 📂 Repository Structure

- `readme.md`
- `sql` -
- `sql/01_stagging`
- `sql/02_dim_&_fact_transformation.sql`
- `sql/03_profitability_view.sql`
- `Airline_Profitability_&_Cost_Driver_Analytics_v1`
- `screenshot` -
- `screenshot/01_Profitability_Deep_Dive`
- `screenshot/02_Cost_Drivers_&_Efficiency`
- `screenshot/03_Network_Performence_Route_Carrier`



## 👤 Author
**Indranil Mukherjee**  
Data Analyst | Power BI • SQL • Analytics
