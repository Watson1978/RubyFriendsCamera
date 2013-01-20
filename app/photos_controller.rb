class PhotosController < UICollectionViewController
  def viewDidLoad
    super
    navigationItem.title = 'RubyFriends'
    navigationController.toolbarHidden = false
    camera_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCamera, target:self, action:'camera_tapped')
    navigationItem.rightBarButtonItem = camera_button
    open_twitter_button = UIBarButtonItem.alloc.initWithTitle('T', style:UIBarButtonItemStyleBordered, target:self, action:'open_twitter')
    open_rubyfriends_button = UIBarButtonItem.alloc.initWithTitle('RF', style:UIBarButtonItemStyleBordered, target:self, action:'open_rubyfriends')
    self.toolbarItems = [open_twitter_button, open_rubyfriends_button]
    collectionView.backgroundColor = UIColor.underPageBackgroundColor
  end

  def viewDidAppear(animated)
    if @image
      open_tweet(@image)
      @image = nil
    end
  end

  def open_twitter
    App.open_url('https://mobile.twitter.com/search?q=%23RubyFriends')
  end

  def open_rubyfriends
    App.open_url('http://rubyfriends.com')
  end

  def camera_tapped
    action_sheet = UIActionSheet.alloc.initWithTitle('Add RubyFriends', delegate:self, cancelButtonTitle:'Cancel', destructiveButtonTitle:nil, otherButtonTitles:'Take Photo', 'Choose from Album', nil)
    action_sheet.showFromToolbar(navigationController.toolbar)
  end

  def actionSheet(action_sheet, clickedButtonAtIndex:button_index)
    case button_index
    when 0 # take photo
      take_picture
    when 1 # choose from album
      open_album
    when action_sheet.cancelButtonIndex
      return
    end
  end

  def take_picture
    BW::Device.camera.rear.picture({media_types: [:image]}, self) do |result|
      @image = result[:original_image]
    end
  end

  def open_album
    BW::Device.camera.any.picture({media_types: [:image]}, self) do |result|
      @image = result[:original_image]
    end
  end

  def open_tweet(image)
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
      tweet_controller = SLComposeViewController.composeViewControllerForServiceType(SLServiceTypeTwitter).tap do |t|
        t.setInitialText(AppDelegate::HASHTAG)
        t.addImage(image)
        t.completionHandler = lambda {|result|
          p image
          if result == SLComposeViewControllerResultDone
            # TODO: 画像を保存
          end
          dismissModalViewControllerAnimated(true)
        }
      end
      presentModalViewController(tweet_controller, animated:true)
    else
      App.alert('Posting twitter is not available.')
    end
  end
end