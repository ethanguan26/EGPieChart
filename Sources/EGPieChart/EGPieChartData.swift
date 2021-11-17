//
//  EGPieCharData.swift
//  EGPieChart
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

open class EGPieChartData {
    open var value: Double
    
    /// Content displayed on slice
    open var content: String?
    
    /// Content displayed outside
    open var outsideContent: String?
    
    open var valueTextColor: UIColor = .black
    open var valueFont: UIFont = UIFont.systemFont(ofSize: 11)
    
    open var outsideValueTextColor: UIColor = .black
    open var outsideValueFont: UIFont = UIFont.systemFont(ofSize: 11)
    
    public init(value: Double, content: String) {
        self.value = value
        self.content = content
    }
}
