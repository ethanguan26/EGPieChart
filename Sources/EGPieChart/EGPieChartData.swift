//
//  EGPieCharData.swift
//  EGPieChart
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

open class EGPieChartData {
    open var value: CGFloat
    
    /// Content displayed on slice
    open var content: String?
    
    /// Content displayed outside
    open var outsideContent: String?
    
    open var valueTextColor: UIColor = .black
    open var valueFont: UIFont = UIFont.systemFont(ofSize: 11)
    
    open var outsideValueTextColor: UIColor = .black
    open var outsideValueFont: UIFont = UIFont.systemFont(ofSize: 11)
    
    open var highlightedOffset: CGFloat = 15.0
    open var isHighlighted = false
    
    public init(value: CGFloat, content: String) {
        self.value = value
        self.content = content
    }
}
