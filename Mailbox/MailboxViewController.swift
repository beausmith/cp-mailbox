//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Beau Smith on 2/20/16.
//  Copyright © 2016 Beau Smith. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class MailboxViewController: UIViewController {

    
    var messageOriginalCenter = CGPoint!()
    var archiveParentOriginalCenter = CGPoint!()
    var laterParentOriginalCenter = CGPoint!()

    var greyColor = UIColor.init(hexString: "e3e3e3")
    var yellowColor = UIColor.init(hexString: "fad333")
    var greenColor = UIColor.init(hexString: "70d962")
    var redColor = UIColor.init(hexString: "eb5433")
    var brownColor = UIColor.init(hexString: "d8a675")

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var archiveParentView: UIView!
    @IBOutlet weak var laterParentView: UIView!
    @IBOutlet weak var archiveIconImageView: UIImageView!
    @IBOutlet weak var deleteIconImageView: UIImageView!
    @IBOutlet weak var laterIconImageView: UIImageView!
    @IBOutlet weak var listIconImageView: UIImageView!
    @IBOutlet weak var rescheduleImageView: UIImageView!
    @IBOutlet weak var listImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: 320, height: feedImageView.frame.height + messageImageView.frame.height)

        messageView.backgroundColor = greyColor
        messageOriginalCenter = messageImageView.center
        archiveParentOriginalCenter = archiveParentView.center
        laterParentOriginalCenter = laterParentView.center
        
        rescheduleImageView.alpha = 0
        listImageView.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
        } else if sender.state == UIGestureRecognizerState.Changed {

            archiveIconImageView.alpha = 0
            deleteIconImageView.alpha = 0
            laterIconImageView.alpha = 0
            listIconImageView.alpha = 0

            messageImageView.center = CGPoint(x: messageOriginalCenter.x + translation.x, y: messageOriginalCenter.y)
            let imageX = messageImageView.frame.origin.x

            laterIconImageView.alpha = convertValue(imageX, r1Min: -25, r1Max: -60, r2Min: 0, r2Max: 1)
            archiveIconImageView.alpha = convertValue(imageX, r1Min: 25, r1Max: 60, r2Min: 0, r2Max: 1)
            
            if imageX >= 60 {
                messageView.backgroundColor = self.greenColor
                archiveParentView.center = CGPoint(x: archiveParentOriginalCenter.x + translation.x - 60, y: archiveParentOriginalCenter.y)
                if imageX >= 260 {
                    messageView.backgroundColor = self.redColor
                    archiveIconImageView.alpha = 0
                    deleteIconImageView.alpha = 1
                }
            } else if imageX <= -60 {
                messageView.backgroundColor = self.yellowColor
                laterParentView.center = CGPoint(x: laterParentOriginalCenter.x + translation.x + 60, y: laterParentOriginalCenter.y)
                if imageX <= -260 {
                    messageView.backgroundColor = self.brownColor
                    laterIconImageView.alpha = 0
                    listIconImageView.alpha = 1
                }
            } else {
                messageView.backgroundColor = self.greyColor
            }

        } else if sender.state == UIGestureRecognizerState.Ended {
            let imageX = messageImageView.frame.origin.x

            switch imageX {
            case let x where x >= 260:
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.messageImageView.center = CGPoint(x: self.messageOriginalCenter.x + 320, y: self.messageOriginalCenter.y)
                    self.archiveParentView.center = CGPoint(x: self.archiveParentOriginalCenter.x + 320 - 60, y: self.archiveParentOriginalCenter.y)
                    self.deleteIconImageView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.scrollView.contentOffset = CGPoint(x: 0, y: 86)
                            }, completion: { (Bool) -> Void in
                                self.messageImageView.center = self.messageOriginalCenter
                                self.archiveParentView.center = self.archiveParentOriginalCenter
                                UIView.animateWithDuration(0, delay: 1.5, options: [], animations: { () -> Void in
                                    self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                                    }, completion: nil
                                )
                        })
                        
                })
            case let x where x >= 60:
                print("archive")
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.messageImageView.center = CGPoint(x: self.messageOriginalCenter.x + 320, y: self.messageOriginalCenter.y)
                    self.archiveParentView.center = CGPoint(x: self.archiveParentOriginalCenter.x + 320 - 60, y: self.archiveParentOriginalCenter.y)
                    self.archiveIconImageView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.scrollView.contentOffset = CGPoint(x: 0, y: 86)
                            }, completion: { (Bool) -> Void in
                                self.messageImageView.center = self.messageOriginalCenter
                                self.archiveParentView.center = self.archiveParentOriginalCenter
                                UIView.animateWithDuration(0, delay: 1.5, options: [], animations: { () -> Void in
                                    self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                                    }, completion: nil
                                )
                        })

                })
            case let x where x <= -260:
                print("list")
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.messageImageView.center = CGPoint(x: self.messageOriginalCenter.x - 320, y: self.messageOriginalCenter.y)
                    self.laterParentView.center = CGPoint(x: self.laterParentOriginalCenter.x - 320 + 60, y: self.laterParentOriginalCenter.y)
                    self.listIconImageView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        self.listImageView.alpha = 1
                })
            case let x where x <= -60:
                print("later - reschedule")
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                        self.messageImageView.center = CGPoint(x: self.messageOriginalCenter.x - 320, y: self.messageOriginalCenter.y)
                        self.laterParentView.center = CGPoint(x: self.laterParentOriginalCenter.x - 320 + 60, y: self.laterParentOriginalCenter.y)
                        self.laterIconImageView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        self.rescheduleImageView.alpha = 1
                })
            default:
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.messageImageView.center = self.messageOriginalCenter
                    }, completion: { (Bool) -> Void in
                })
            }
        }
    }
    
    @IBAction func didTapReschedule(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.rescheduleImageView.alpha = 0
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 86)
                    }, completion: { (Bool) -> Void in
                        self.messageImageView.center = self.messageOriginalCenter
                        self.laterParentView.center = self.laterParentOriginalCenter
                        UIView.animateWithDuration(0, delay: 1.5, options: [], animations: { () -> Void in
                            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                            }, completion: nil
                        )
                })
        })
    }
    
    @IBAction func didTapList(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.listImageView.alpha = 0
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 86)
                    }, completion: { (Bool) -> Void in
                        self.messageImageView.center = self.messageOriginalCenter
                        self.laterParentView.center = self.laterParentOriginalCenter
                        UIView.animateWithDuration(0, delay: 1.5, options: [], animations: { () -> Void in
                            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                            }, completion: nil
                        )
                })
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
