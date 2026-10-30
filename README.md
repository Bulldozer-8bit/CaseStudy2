
graph TB
    %% Style Definitions
    classDef main fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef p1 fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px;
    classDef p2 fill:#e8f5e9,stroke:#388e3c,stroke-width:1px;
    classDef p3 fill:#fff3e0,stroke:#f57c00,stroke-width:1px;
    classDef core fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px,stroke-dasharray: 5 5;

    subgraph "Global Deployment Environment"
        Deploy[make_deployment <br/> Generate Random Robot Swarm Deployment D]:::main
        Main[Main Execution and Testing Script]:::main
    end

    subgraph "Part I: Communication Network Construction"
        MC[make_complete]:::p1
        MS[make_star]:::p1
        MR[make_ring]:::p1
        MD[make_disk]:::p1
        GS[graph_stats <br/> Calculate Network Degree and Diameter]:::p1
    end

    subgraph "Part II: Basic Rendezvous Protocols"
        SL[simulate_linear <br/> Simulate Pure Linear Dynamics Without Anchors]:::p2
    end

    subgraph "Part III: Mission Design and Evaluation"
        CL([choose_leaders <br/> Core Objective: Leader Selection Strategy]):::core
        SA[simulate_anchored <br/> Simulate Dynamics with Anchors and Faulty Robots]:::p3
        SM[score_mission <br/> Calculate Mission Score Based on Percentage Distance Reduction]:::p3
    end

    %% Data Flow and Dependencies
    Deploy -->|Generate Deployment Parameters: P0, faulty, g, m| Main
    Main -->|Pass Parameters| MD
    Main -->|Validate Network Properties| MC & MS & MR & MD
    MC & MS & MR & MD -.->|Generated Adjacency Matrix G| GS

    MD -->|Network Structure G and Deployment Data D| CL
    CL -->|Output Leader Index Set S| SM
    Deploy -->|Complete Deployment Structure D| SM

    SM -->|Construct Anchored Dynamics Model| SA
    SA -->|Return Robot Trajectories over T Steps| SM
    SM -->|Calculate Mean Squared Error and Mission Score| Main

    %% Independent Functionality
    Main -.->|Test Initial Rendezvous Protocol| SL

