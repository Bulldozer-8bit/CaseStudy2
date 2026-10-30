graph TB
    classDef main fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef p1 fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px;
    classDef p2 fill:#e8f5e9,stroke:#388e3c,stroke-width:1px;
    classDef p3 fill:#fff3e0,stroke:#f57c00,stroke-width:1px;
    classDef core fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px,stroke-dasharray: 5 5;

    subgraph "Deployment Workspace"
        Deploy[make_deployment <br/> deploy D]:::main
        Main[主运行/测试脚本]:::main
    end

    subgraph "Part I: Communication Networks"
        MC[make_complete]:::p1
        MS[make_star]:::p1
        MR[make_ring]:::p1
        MD[make_disk]:::p1
        GS[graph_stats <br/> calculating degrees and radius]:::p1
    end

    subgraph "Part II: Rendezvous Protocols"
        SL[simulate_linear <br/> simulate]:::p2
    end

    subgraph "Part III: Mission Design"
        CL([choose_leaders <br/> 核心目标：你的选拔策略]):::core
        SA[simulate_anchored <br/> 带锚点/故障机器人的仿真]:::p3
        SM[score_mission <br/> 计算距离缩减百分比得分]:::p3
    end

    %% 数据流向关联
    Deploy -->|生成部署参数: PO, faulty, g, m| Main
    Main -->|参数传入| MD
    Main -->|验证图属性| MC & MS & MR & MD
    MC & MS & MR & MD -.->|生成的邻接矩阵 G| GS
    
    MD -->|网络结构 G 与部署数据 D| CL
    CL -->|输出领导者索引集合 S| SM
    Deploy -->|完整部署结构 D| SM
    
    SM -->|构建包含锚点的动力学模型| SA
    SA -->|返回 T 步内的机群运动轨迹| SM
    SM -->|计算均方误差并打分| Main
    
    %% 独立功能
    Main -.->|早期集结协议测试| SL
