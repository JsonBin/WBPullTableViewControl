# WBPullTableViewControl
###Swift 写的一款 简单的下拉选择菜单栏 可根据实际情况，自动排出所需要的菜单

使用教程
========

* 初始化

        // iOS7.0之后自动调整，需关闭
        self.automaticallyAdjustsScrollViewInsets = false
        // 初始化按钮数据
        let btarray = ["菜单栏1", "菜单栏2", "菜单栏3"]
        // 初始化菜单栏数据
        let tbarray = [[["菜单栏1-1", "菜单栏1-2", "菜单栏1-3"]], [["菜单栏2-1", "菜单栏2-2", "菜单栏2-3"],["菜单栏2-1-1", "菜单栏2-1-2", "菜单栏2-1-3"]], [["菜单栏3-1", "菜单栏3-2", "菜单栏3-3"],["菜单栏3-1-1", "菜单栏3-1-2", "菜单栏3-1-3" ,"菜单栏3-1-4"],["菜单栏3-2-1", "菜单栏3-2-2", "菜单栏3-2-3"]]]
        
        // 加载页面
        let custonMenu = WBCustomTableMenu.init(frame: CGRectMake(0, 64, getWidth(), 40))
        custonMenu.buttonArray = btarray
        custonMenu.tableDataArray = tbarray
        custonMenu.creatMenuInView(self.view)
        
* 自定义属性

        // 设置属性(可不设置，则用默认属性)
        custonMenu.buttonTitleFont = 11   // 设置按钮的字体大小，默认为11
        custonMenu.maskViewColor = UIColor.whiteColor()   // 设置遮罩的颜色
        custonMenu.maskViewTime = 0.5  // 设置遮罩动画时间，默认为0.2
        custonMenu.cellHeight = 30    // 设置cell的高度，默认为30
        custonMenu.cellTextFont = 10  // 设置cell中字体的大小，默认为10
        
* 回调，点击完成之后回调
        
        // 选择菜单回调(选择完成之后回调)
        custonMenu.initSelectMenu { (string) in
            
            print(string)
        }

效果图
=======
![gif](https://github.com/JsonBin/WBPullTableViewControl/raw/master/WBPullTableViewControl/tableview.gif "下拉选择菜单")
