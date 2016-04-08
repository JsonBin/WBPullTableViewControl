//
//  WBCustomTableMenu.swift
//  WBPullTableViewControl
//
//  Created by Zwb on 16/4/7.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit
typealias  SelectBlock = (string:NSString) -> Void

class WBCustomTableMenu: UIView, UITableViewDelegate, UITableViewDataSource , UIGestureRecognizerDelegate{
    
    // 外部调用
    internal var buttonArray         = NSArray()  // button 标题
    internal var tableDataArray      = NSArray()  // tableview 数据
    internal var buttonTitleFont     : CGFloat?   // 设置按钮的字体大小
    internal var maskViewColor       : UIColor?   // 设置遮罩颜色
    internal var maskViewTime        : CGFloat?   // 设置遮罩动画时间
    internal var cellHeight          : CGFloat?   // 设置每个cell的高度
    internal var cellTextFont        : CGFloat?   // 设置每个cell的字体大小
    internal var selectblock:SelectBlock?
    
    // 内部调用
    private var backView            = UIView()
    private var tableView           = UITableView()
    private var lastSelectedIndex   = NSInteger()
    private var lastSelectedCell    = NSInteger()
    private var menuBaseHeight      = CGFloat()
    private var tableViewWith       = CGFloat()
    private var tableViewShow       = Bool()
    private var bgLayers            = NSMutableArray()
    private var tableArray          = NSMutableArray()
    private var dataArray           = NSArray()
    private var lastData            = Bool()  // 记录是否最后一个tableview的数据
    
    // 选择回调
    internal func initSelectMenu(select:SelectBlock)-> Void{
        selectblock = select
    }
    
    // 创建按钮菜单
    internal func creatMenuInView(view:UIView) -> Void {
        view.addSubview(self)
        lastSelectedIndex = -1;
        menuBaseHeight = self.frame.size.height
        self.backgroundColor = maskViewColor==nil ? UIColor ( red: 0.702, green: 0.702, blue: 0.702, alpha: 1.0 ) : maskViewColor
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, getWidth(), menuBaseHeight);
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(WBCustomTableMenu.remove))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        backView = UIView.init(frame: CGRectMake(0, 0, getWidth(), menuBaseHeight))
        backView.userInteractionEnabled = true;
        backView.backgroundColor = UIColor.whiteColor()
        self.addSubview(backView)
        // 添加按钮
        for index in 0..<buttonArray.count {
            button(index+100)
        }
        // 添加线条
        let VlineLbTop = UILabel.init(frame: CGRectMake(0, 0, backView.frame.size.width, 1))
        VlineLbTop.backgroundColor = UIColor.lightGrayColor()
        let VlineLbBom = UILabel.init(frame: CGRectMake(0, menuBaseHeight, backView.frame.size.width, 1))
        VlineLbBom.backgroundColor = UIColor.lightGrayColor()
        backView.addSubview(VlineLbTop)
        backView.addSubview(VlineLbBom)
        
        // 添加tableview
        for i in 0..<buttonArray.count {
            let array = NSMutableArray()
            for j in 0..<tableDataArray[i].count {
                array.addObject(creatTableview(tableDataArray[i] as! NSArray, offx: j))
            }
            tableArray.addObject(array)
        }
    }
    
    internal func remove() -> Void{
        tableViewShow = false
        weak var weakSelf = self
        let layer:CALayer = bgLayers[(lastSelectedIndex-100)] as! CALayer
        layer.transform = CATransform3DMakeRotation(CGFloat(M_PI*2), 0, 0, 1);
        let array = tableArray[lastSelectedIndex-100]
        for i in 0..<array.count {
            let tabview:UITableView = array[i] as! UITableView
            UIView.animateWithDuration(0.2, animations: {
                tabview.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(i), CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, 0)
                weakSelf?.hiddeMaskView()
            })
        }
        hiddeMaskView()
    }
    
    // 创建button
    private func button(tag:NSInteger) -> Void {
        let num = buttonArray.count
        let width = getWidth()/CGFloat(num)
        let button = UIButton.init(type: .Custom)
        button.bounds = CGRectMake(0, 0, width, 44)
        button.center = CGPointMake(width/2+width*CGFloat(tag-100), 22)
        button.setTitle(buttonArray[(tag-100)] as? String, forState: .Normal)
        button.backgroundColor = UIColor.whiteColor()
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel?.font = buttonTitleFont==nil ? UIFont.systemFontOfSize(11) : UIFont.systemFontOfSize(buttonTitleFont!)
        button.tag = tag
        button.addTarget(self, action:#selector(WBCustomTableMenu.buttonClicked(_:)), forControlEvents: .TouchUpInside)
        
        // 设置三角形
        let bgLayerPoint = CGPointMake(getWidth()/CGFloat(num)-10, menuBaseHeight/2);
        let bgLayer = createBgLayerWithColor(UIColor.clearColor(), andPosition: bgLayerPoint)
        let indicatorPoint = CGPointMake(10, 10);
        let indicator = createIndicatorWithColor(UIColor.lightGrayColor(), andPosition: indicatorPoint)
        bgLayer.addSublayer(indicator)
        bgLayers.addObject(bgLayer)
        button.layer.addSublayer(bgLayer)
        backView.addSubview(button)
        
        let btnW = (getWidth()-CGFloat(num)+1)/CGFloat(num)
        let lineLb = UILabel.init(frame: CGRectMake((btnW+1)*CGFloat(tag-100)+btnW, menuBaseHeight/10, 1, menuBaseHeight/10*8))
        lineLb.backgroundColor = UIColor.lightGrayColor()
        if (tag-100 == num) {
            lineLb.hidden = true
        }
        backView.addSubview(lineLb)
        
    }
    
    // 创建tableview
    private func creatTableview(array:NSArray ,offx:NSInteger) -> UITableView {
        let width = getWidth()/CGFloat(array.count)
        dataArray = array[offx] as! NSArray
        tableView = UITableView.init(frame: CGRectMake(width*CGFloat(offx), getHeight(), width, 0), style: .Plain)
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.dataSource = self
        tableView.delegate = self
        self.insertSubview(tableView, belowSubview: backView)
        return tableView
    }
    
    private func createIndicatorWithColor(color:UIColor, andPosition:CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path  = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(10, 0))
        path.addLineToPoint(CGPointMake(5, 7))
        path.closePath()
        
        layer.path = path.CGPath;
        layer.lineWidth = 0.8;
        layer.fillColor = UIColor ( red:127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0 ).CGColor
        let bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, CGLineCap.Butt, CGLineJoin.Miter, layer.miterLimit);
        layer.bounds = CGPathGetBoundingBox(bound);
        layer.position = andPosition
        return layer;
    }
    
    private func createBgLayerWithColor(color:UIColor, andPosition:CGPoint) -> CALayer {
        let layer = CALayer()
        layer.position = andPosition
        layer.bounds = CGRectMake(0, 0, 20, 20);
        layer.backgroundColor = color.CGColor;
        return layer;
    }
    
    internal func buttonClicked(sender:UIButton) -> Void {
        weak var weakSelf = self
        if lastSelectedIndex != sender.tag && lastSelectedIndex != -1 {
            let layer:CALayer = bgLayers[(lastSelectedIndex-100)] as! CALayer
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI)*2, 0, 0, 1)
            let array = tableArray[lastSelectedIndex-100]
            for i in 0..<array.count {
                UIView.animateWithDuration(0.1, animations: {
                    let tabview:UITableView = array[i] as! UITableView
                    tabview.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(i), CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, 0)
                })
            }
            tableViewShow = false
            showTableView(sender.tag)
            
        }else{
            showTableView(sender.tag)
        }
    }
    
    private func showTableView(index:NSInteger) -> Void {
        weak var weakSelf = self
        changeTableVewWidth(tableDataArray[index-100] as! NSArray)
        let count = tableDataArray[index-100][0].count
        let height = cellHeight != nil ? cellHeight : 30
        if !tableViewShow {
            tableViewShow = true
            showMaskView()
            let layer:CALayer = bgLayers[(index-100)] as! CALayer
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1);
            dataArray = tableDataArray[index-100][0] as! NSArray
            if tableDataArray[index-100].count==1 {
                lastData = true
            }else{
                lastData = false
            }
            let tabview:UITableView = tableArray[index-100][0] as! UITableView
            tabview.frame = CGRectMake(0, CGRectGetMaxY(backView.frame), tableViewWith, 0)
            UIView.animateWithDuration(0.2, animations: {
                tabview.frame = CGRectMake(0, CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, height!*CGFloat(count))
                tabview.reloadData()
            })
        }else{
            tableViewShow = false
            let layer:CALayer = bgLayers[(index-100)] as! CALayer
            layer.transform = CATransform3DMakeRotation(CGFloat(M_PI*2), 0, 0, 1);
            let array = tableArray[index-100]
            for i in 0..<array.count {
                let tabview:UITableView = array[i] as! UITableView
                tabview.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(i), CGRectGetMaxY(self.backView.frame), (weakSelf?.tableViewWith)!, height!*CGFloat(count))
                dataArray = tableDataArray[index-100][i] as! NSArray
                if i==array.count-1 {
                    lastData = true
                }else{
                    lastData = false
                }
                UIView.animateWithDuration(0.2, animations: {
                    tabview.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(i), CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, 0)
                    tabview.reloadData()
                })
            }
            hiddeMaskView()
        }
        lastSelectedIndex = index
    }
    
    private func showNextTableView(index:NSInteger) -> Void{
        weak var weakSelf = self
        let height = cellHeight != nil ? cellHeight : 30
        let count = tableDataArray[lastSelectedIndex-100][index].count
        dataArray = tableDataArray[lastSelectedIndex-100][index] as! NSArray
        if index==tableDataArray[lastSelectedIndex-100].count-1 {
            lastData = true
        }else{
            lastData = false
        }
        for i in 0..<tableArray[lastSelectedIndex-100].count {
            if i>index {
                let tabview1:UITableView = tableArray[lastSelectedIndex-100][i] as! UITableView
                UIView.animateWithDuration(0.2, animations: {
                    tabview1.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(i), CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, 0)
                })
            }
        }
        let tabview:UITableView = tableArray[lastSelectedIndex-100][index] as! UITableView
        tabview.frame = CGRectMake(tableViewWith*CGFloat(index), CGRectGetMaxY(backView.frame), tableViewWith, 0)
        UIView.animateWithDuration(0.2, animations: {
            tabview.frame = CGRectMake((weakSelf?.tableViewWith)!*CGFloat(index), CGRectGetMaxY((weakSelf?.backView.frame)!), (weakSelf?.tableViewWith)!, height!*CGFloat(count))
            tabview.reloadData()
        })
    }
    
    private func changeTableVewWidth(array:NSArray) -> Void{
        tableViewWith = getWidth()/CGFloat(array.count)
    }
    
    private func showMaskView() -> Void{
        if maskViewTime==nil {
            maskViewTime = 0.2
        }
        weak var weakSelf = self
        UIView.animateWithDuration(Double(maskViewTime!)) {
            // 放大view
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (UIScreen.mainScreen().bounds.size.height)-self.frame.origin.y);
            self.backgroundColor = weakSelf?.maskViewColor==nil ? UIColor ( red: 0.702, green: 0.702, blue: 0.702, alpha: 1.0 ) : weakSelf?.maskViewColor
        }
    }
    
    internal func hiddeMaskView() -> Void {
        if maskViewTime==nil {
            maskViewTime = 0.2
        }
        weak var weakSelf = self
        UIView.animateWithDuration(Double(maskViewTime!)) {
            // 放大view
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (weakSelf?.menuBaseHeight)!);
            self.backgroundColor = weakSelf?.maskViewColor==nil ? UIColor ( red: 0.702, green: 0.702, blue: 0.702, alpha: 1.0 ) : weakSelf?.maskViewColor
        }
    }
    
    //MARK: --- UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKindOfClass(UIButton) || NSStringFromClass(touch.view!.classForKeyedArchiver!)=="UITableViewCellContentView" {
            return false
        }else{
            return true
        }
    }
    
    //MARK: ----- UITableViewDataSource
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell.init(style:.Default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text=dataArray[indexPath.row] as? String
        cell?.textLabel?.font = cellTextFont==nil ? UIFont.systemFontOfSize(10) : UIFont.systemFontOfSize(cellTextFont!)
        if lastData {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }else{
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell!
    }
    
    //MARK: -- UITableViewDelegate
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = cellHeight != nil ? cellHeight : 30
        return height!
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 判断下一个tableview存不存在
        let index = tableArray[lastSelectedIndex-100].indexOfObject(tableView)+1
        if tableArray[lastSelectedIndex-100].count==1 {
            remove()
            if selectblock != nil {
                selectblock!(string: dataArray[indexPath.row] as! NSString)
            }
        }else{
            if index==1 {
                showNextTableView(index)
            }else{
                if index==lastSelectedCell {
                    showNextTableView(index)
                }else{
                    if lastData {
                        remove()
                        if selectblock != nil {
                            selectblock!(string: dataArray[indexPath.row] as! NSString)
                        }
                    }else{
                        showNextTableView(index)
                    }
                }
            }
        }
        lastSelectedCell = index
    }
    
    private func getWidth() -> CGFloat {
        return self.bounds.size.width
    }
    
    private func getHeight() -> CGFloat {
        return self.bounds.size.height
    }
}
