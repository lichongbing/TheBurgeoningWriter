# TheBurgeoningWriter
Siri Shortcuts Tutorial in iOS 12
<div class="c-written-tutorial__content l-block l-block--688" role="article">


<p>If you’ve had an iPhone for any length of time, you’ve likely interacted with Siri. When Siri was <a href="https://www.youtube.com/watch?v=agzItTz35QQ" target="_blank" rel="noopener">first announced</a> in 2011, its ability to understand context and meaning, regardless of the specific combination of words used, was groundbreaking.</p>
<p>Unfortunately, Siri integration was limited to Apple’s own apps until the release of <em>SiriKit</em> in 2016. Even then, the types of things you could do with Siri were limited to a particular set of domains.</p>
<p>With the release of <em>Siri Shortcuts</em> in iOS 12, this is no longer the case. Now, you can create custom intents to represent any domain, and you can expose your app’s services directly to Siri.</p>
<p>In this tutorial, you’ll learn how to use these new shortcuts APIs to integrate Siri into a writing app.</p>
<h2 id="toc-anchor-001">Getting Started</h2>
<p>To get started, use the <em>Download Materials</em> button at the top or bottom of this tutorial to download the starter project.</p>
<p>Once downloaded, double-click <em>TheBurgeoningWriter.xcodeproj</em> to open the project in Xcode.</p>
<div class="note">
<em>Note</em>: If possible, you should use a physical device to follow along with this tutorial. Although the Simulator works, it behaves differently with a few things.
</div>
<p>Set the bundle ID to something unique to you (Apple recommends using a reverse DNS name such as com.razeware.TheBurgeoningWriter). Then, run the app, and you’ll see a home screen that shows all of the written articles. From here, you can add new articles and publish the drafts you’ve previously saved.</p>
<p>The big idea here is to write an article, sit on it for a little bit, and then publish it later — provided you’re still happy with it.</p>
<p>Ready to begin? Great!</p>
<h3 id="toc-anchor-002">Adding Shortcuts to an App</h3>
<p>The first thing to consider is which features of your app are appropriate for turning into shortcuts.</p>
<p>Ideally, you should create shortcuts for actions your user can perform; preferably, something they’ll likely do repeatedly. Once you’ve decided to set up a shortcut, there are two ways to create it:</p>
<ol>
<li>
<em>NSUserActivity</em>: User activities are part of an existing API that allows you to expose certain things a user can do for app hand-off and Spotlight searches. The thing to remember here is that this option is only useful when you want the user to go from Siri into your app to complete a task.</li>
<li>
<em>Custom Intents</em>: Creating a custom intent is the true power of shortcuts. With an intent, you can communicate with your user via Siri without ever having to open your app.</li>
</ol>
<h2 id="toc-anchor-003">Making a Shortcut for Writing New Articles</h2>
<p>Your first shortcut is one that lets a user go straight to the new article screen. This is the perfect candidate for creating a shortcut based on an <code>NSUserActivity</code> object, because it’ll take the user from Siri into your app.</p>
<p>Your goal is to donate one of these activities to the system every time your user performs that action. You’ll do so by adding a new method that allows you to generate these activity objects.</p>
<p>Open <em>Article.swift</em> and, at the top of the file under the imports, add the following constant string definition:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">public</span> <span class="hljs-keyword">let</span> kNewArticleActivityType = <span class="hljs-string">"com.razeware.NewArticle"</span>
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>This is the identifier you’ll use to determine if you’re dealing with a “new article” shortcut. A good rule of thumb is to use the reverse DNS convention when choosing an identifier for your shortcut.</p>
<p>Next, below the properties, add the following method definition:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">newArticleShortcut</span><span class="hljs-params">(thumbnail: UIImage?)</span></span> -&gt; <span class="hljs-type">NSUserActivity</span> {
  <span class="hljs-keyword">let</span> activity = <span class="hljs-type">NSUserActivity</span>(activityType: kNewArticleActivityType)
  activity.persistentIdentifier = 
    <span class="hljs-type">NSUserActivityPersistentIdentifier</span>(kNewArticleActivityType)

<span class="hljs-keyword">return</span> activity
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<p>Here, you’re creating an activity object with the correct identifier and returning it. The <code>persistentIdentifier</code> is what connects all of these shortcuts as one activity.</p>
<p>For your activity to be useful, you have to do some configuration.</p>
<p>Add the following two lines before the <code>return</code>:</p>
<pre lang="swift" class="language-swift hljs">activity.isEligibleForSearch = <span class="hljs-literal">true</span>
activity.isEligibleForPrediction = <span class="hljs-literal">true</span>
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>First, you set <code>isEligibleForSearch</code> to <code>true</code>. This allows users to search for this feature in Spotlight. You then set <code>isEligibleForPrediction</code> to <code>true</code> so prediction works. Setting this to <code>true</code> allows Siri to look at the activity and suggest it to your users in the future. It’s also what allows the activity to be turned into a Shortcut later.</p>
<p>Next, you’ll set the properties that affect how your Shortcut looks to users.</p>
<p>Define a local attributes property. Add it below the previously pasted lines:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> attributes = <span class="hljs-type">CSSearchableItemAttributeSet</span>(itemContentType: kUTTypeItem <span class="hljs-keyword">as</span> <span class="hljs-type">String</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Set your attributes by adding the following lines:</p>
<pre lang="swift" class="language-swift hljs">activity.title = <span class="hljs-string">"Write a new article"</span>
attributes.contentDescription = <span class="hljs-string">"Get those creative juices flowing!"</span>
attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: <span class="hljs-number">1.0</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>This sets the title, subtitle and thumbnail image you’ll see on the suggestion notification.</p>
<p>Stepping back for a moment, it’s important to remember that Siri exposes this feature in two separate ways: </p>
<ul>
<li>First, Siri learns to predict what your users might want to do in the form of suggestions that pop up in <em>Notification Center</em> and <em>Spotlight Search</em>.</li>
<li>Second,  your users can turn these activities into voice-based shortcuts.</li>
</ul>
<p>For the last bit of configuration, add the suggested phrase users should consider when making a shortcut for this activity:</p>
<pre lang="swift" class="language-swift hljs">activity.suggestedInvocationPhrase = <span class="hljs-string">"Time to write!"</span>
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>The chosen phrase should be something that’s short and easy to remember. It should also not include the phrase “Hey, Siri” because the user might have already triggered Siri’s interface that way.</p>
<p>Finally, assign the attributes object to the activity object:</p>
<pre lang="swift" class="language-swift hljs">activity.contentAttributeSet = attributes
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Now that you can grab user activity objects from an <code>Article</code>, it’s time to use them.</p>
<h3 id="toc-anchor-004">Using the Activity Object</h3>
<p>Open <em>ArticleFeedViewController.swift</em> and locate <code>newArticleWasTapped()</code>.</p>
<p>Below the comment, add the following lines:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-comment">//1</span>
<span class="hljs-keyword">let</span> activity = <span class="hljs-type">Article</span>.newArticleShortcut(thumbnail: <span class="hljs-type">UIImage</span>(named: <span class="hljs-string">"notePad"</span>))
vc.userActivity = activity

<span class="hljs-comment">//2</span>
activity.becomeCurrent()
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<ol>
<li>First, you create an activity object. Then, you attach it to the view controller that’ll be on screen.</li>
<li>Next, you call <code>becomeCurrent()</code> to officially become the “current” activity. This is the method that registers your activity with the system.</li>
</ol>
<p>Congratulations, you’re now successfully donating this activity to Siri.</p>
<p>Build and run. Then, go to the new article screen and back to the home screen a few times. </p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/NewBackAndForth.gif" alt="" width="254" height="454" class="aligncenter size-full bordered wp-image-200670"></p>
<p>You won’t see anything too interesting in the app, but each time you perform that action, you’re donating an activity to the system.</p>
<p>To verify, pull down on the home screen to go to search. Then, type “write”, and you should see the “Write a new article” action come up.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/07/SearchForWriting.png" alt="" width="250" class="aligncenter size-full bordered wp-image-200408" srcset="https://koenig-media.raywenderlich.com/uploads/2018/07/SearchForWriting.png 1125w, https://koenig-media.raywenderlich.com/uploads/2018/07/SearchForWriting-148x320.png 148w, https://koenig-media.raywenderlich.com/uploads/2018/07/SearchForWriting-231x500.png 231w" sizes="(max-width: 1125px) 100vw, 1125px"></p>
<h3 id="toc-anchor-005">Continuing a User Activity</h3>
<p>Tap on the “Write a new article” result in your search. You’ll be taken to your app’s home screen.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510.png" alt="" width="300" class="aligncenter size-full wp-image-200690" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510.png 510w, https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510-250x250.png 250w, https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510-320x320.png 320w, https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510-500x500.png 500w" sizes="(max-width: 510px) 100vw, 510px"></p>
<p>Your feature may be exposed to the system, but your app isn’t doing anything when the system tells it the user would like to use the feature.</p>
<p>To react to this request, open <em>AppDelegate.swift</em>, and at the bottom of the class, add the following method definition:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">application</span><span class="hljs-params">(
  <span class="hljs-number">_</span> application: UIApplication,
  <span class="hljs-keyword">continue</span> userActivity: NSUserActivity,
  restorationHandler: @escaping <span class="hljs-params">([UIUserActivityRestoring]?)</span></span></span> -&gt; <span class="hljs-type">Void</span>
) -&gt; <span class="hljs-type">Bool</span> {
  <span class="hljs-keyword">return</span> <span class="hljs-literal">true</span>
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Inside the method and before the <code>return</code> statement, create the New Article view controller and push it onto the nav stack:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> vc = <span class="hljs-type">NewArticleViewController</span>()
nav?.pushViewController(vc, animated: <span class="hljs-literal">false</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Build and run again. When you search for this feature and tap on it, your app takes you directly to the New Article screen.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/SuccessfulShortcut.gif" alt="" width="250" class="aligncenter size-full bordered wp-image-200693"></p>
<h3 id="toc-anchor-006">Developer Settings for Working With Siri</h3>
<p>All you’ve done so far is accessed your feature from Spotlight. This isn’t anything new, and it would work even if Siri weren’t involved since you made your activity eligible for search.</p>
<p>To prove that Siri can start suggesting this action, you’ll need to go to the Settings app and enable a few options.</p>
<p>Open <em>Settings</em> and find the <em>Developer</em> option. Scroll towards the bottom and you’ll see a section named <em>SHORTCUTS TESTING</em>.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/ShortcutsTestingOff.png" alt="" width="250" class="aligncenter size-full bordered wp-image-200678" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/ShortcutsTestingOff.png 750w, https://koenig-media.raywenderlich.com/uploads/2018/08/ShortcutsTestingOff-180x320.png 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/ShortcutsTestingOff-281x500.png 281w" sizes="(max-width: 750px) 100vw, 750px"></p>
<p>Turning on the <em>Display Recent Shortcuts</em> option means that recently donated shortcuts will show up in <em>Spotlight Search</em> instead of Siri’s current predictions.</p>
<p>Similarly, <em>Display Donations on Lock Screen</em> always shows your recent donations as a notification on your lock screen.</p>
<p>Turn on both of the options so you can always see what shortcuts your app has donated most recently.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/donationsOnLockscreen.png" alt="" width="250" class="aligncenter size-full bordered wp-image-200680" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/donationsOnLockscreen.png 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/donationsOnLockscreen-180x320.png 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/donationsOnLockscreen-281x500.png 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<p>Now that you know how to see what Siri’s suggestions look like, it’s time to turn these activities into full-blown shortcuts!</p>
<h2 id="toc-anchor-007">Turning User Activities Into Shortcuts</h2>
<p>When a user wants to turn one of these activities into a shortcut, they can do so from the Settings app. As the developer, there’s nothing more you need to do.</p>
<p>To test it out: On your device, open <em>Settings &gt; Siri &amp; Search</em>. </p>
<p>The first section shows a list of shortcuts donated by the different apps on your phone. You’ll see the “Write a new article” shortcut in this list; if you don’t, tap <em>More Shortcuts</em> to see more.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/MakeShortcuts.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200684" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/MakeShortcuts.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/MakeShortcuts-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/MakeShortcuts-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<p>To add a shortcut for this action, tap the action, and you’ll be taken to the shortcut creation screen.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/AddToSiri.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200685" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/AddToSiri.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/AddToSiri-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/AddToSiri-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<p>Here, you can see that suggested invocation phrase you added earlier. </p>
<p>Tap the red circle at the bottom. When prompted, say to Siri, “Time to write”. After Siri figures out what you said, tap <em>Done</em> to finalize your shortcut.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/Done.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200687" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/Done.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/Done-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/Done-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<p>Now, your shortcut is listed along with any other shortcuts you’ve created.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/myShortcuts.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200688" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/myShortcuts.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/myShortcuts-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/myShortcuts-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<h2 id="toc-anchor-008">Adding Shortcuts To Siri From Your App</h2>
<p>This is all well and good, but can you expect users to muck around in the Settings app to add a shortcut for your app? Nope! Not at all.</p>
<p>Fortunately, you can prompt your users to do this straight from your app!</p>
<p>Open <em>NewArticleViewController.swift</em> and you’ll see an empty definition for <code>addNewArticleShortcutWasTapped()</code>.</p>
<p>This is the method that gets called when the blue “Add Shortcut to Siri” button is tapped. </p>
<p>The <em>IntentsUI</em> framework provides a special view controller that you can initialize with a shortcut. You can then present this view controller to show the same UI you just saw in the Settings app.</p>
<p>Add the following two lines to initialize the shortcut:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> newArticleActivity = <span class="hljs-type">Article</span>
  .newArticleShortcut(thumbnail: <span class="hljs-type">UIImage</span>(named: <span class="hljs-string">"notePad.jpg"</span>))
<span class="hljs-keyword">let</span> shortcut = <span class="hljs-type">INShortcut</span>(userActivity: newArticleActivity)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Next, create the view controller, set the delegate and present the view:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> vc = <span class="hljs-type">INUIAddVoiceShortcutViewController</span>(shortcut: shortcut)
vc.delegate = <span class="hljs-keyword">self</span>

present(vc, animated: <span class="hljs-literal">true</span>, completion: <span class="hljs-literal">nil</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<p>At this point, Xcode complains that this class isn’t fit to be the delegate of that view controller. You’ll need to fix this.</p>
<p>Add the following extension at the bottom of the file:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-class"><span class="hljs-keyword">extension</span> <span class="hljs-title">NewArticleViewController</span>: <span class="hljs-title">INUIAddVoiceShortcutViewControllerDelegate</span> </span>{
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Then, conform to the <code>INUIAddVoiceShortcutViewControllerDelegate</code> protocol by adding the method for when the user successfully creates a shortcut:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">addVoiceShortcutViewController</span><span class="hljs-params">(
  <span class="hljs-number">_</span> controller: INUIAddVoiceShortcutViewController,
  didFinishWith voiceShortcut: INVoiceShortcut?,
  error: Error?
)</span></span> {
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Also, add the method for when the user taps the <em>Cancel</em> button:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">addVoiceShortcutViewControllerDidCancel</span><span class="hljs-params">(
  <span class="hljs-number">_</span> controller: INUIAddVoiceShortcutViewController)</span></span> {
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Next, you need to dismiss the Siri view controller when these methods are called.</p>
<p>Add the following line to both methods:</p>
<pre lang="swift" class="language-swift hljs">dismiss(animated: <span class="hljs-literal">true</span>, completion: <span class="hljs-literal">nil</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Build and run to try it out! Go to the New Article view and tap <em>Add Shortcut to Siri</em>. </p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/InAppSiri.gif" alt="" width="250" class="aligncenter size-full bordered wp-image-200695"></p>
<p>You’ll see a view controller that looks a lot like the view you see when you go to set up shortcuts in the Settings app. With this in place, your users won’t have excuses for not utilizing your app’s full potential! :]</p>
<h2 id="toc-anchor-009">Publishing Articles with Siri</h2>
<p>Next, you want to add the ability to publish articles you’ve written directly from Siri. The big difference here is that instead of Siri opening your app, everything will happen in-line, directly from the Siri UI.</p>
<p>For this shortcut, you’ll create a custom <em>Intent</em> to define the back and forth between Siri, your users and your app.</p>
<h3 id="toc-anchor-010">Defining a Custom Writing Intent</h3>
<p>In the Project navigator, locate the <em>ArticleKit</em> folder and click on it to highlight it.</p>
<p>Then, press <em>Command + N</em> to create a new file.</p>
<p>In the filter search box, type <em>Intent</em> and you’ll see <em>SiriKit Intent Definition File</em>.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM-650x428.png" alt="add intent definition file" width="650" height="428" class="aligncenter size-large bordered wp-image-209295" srcset="https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Click <em>Next</em>, then name your file <em>ArticleIntents.intentdefinition</em>.</p>
<p>Now it’s time to create an intent for posting articles you’ve written. </p>
<p>Go to the bottom of the section that reads <em>No Intents</em> and click the plus button to add a new intent definition.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents-650x429.png" alt="add new intent" width="650" height="429" class="aligncenter size-large bordered wp-image-209335" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents-650x429.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents-480x317.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents.png 1396w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Name it <em>PostArticle</em>, and then configure your intent based on these settings (described after the picture):</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2-650x428.png" alt="PostArticleIntent definition" width="650" height="428" class="aligncenter size-large bordered wp-image-209336" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>This screen is for configuring the information that the publish intent needs to work.</p>
<p>The options in the <em>Custom Intent</em> section define what type of intent it is and can affect how Siri talks about the action. Telling Siri that this is a <em>Post</em> type action lets the system know that you’re sharing some bit of content somewhere:</p>
<ol>
<li>
<em>Category</em>: Post</li>
<li>
<em>Title</em>: Post Article</li>
<li>
<em>Description</em>: Post the last article</li>
<li>
<em>Default Image</em>: Select one of the existing images in the project.</li>
<li>
<em>Confirmation</em>: Check this box since you want to ask the user to verify that they’re really ready to publish this article.</li>
</ol>
<p>The <em>Parameters</em> section is where you define any dynamic properties used in the <em>Title</em> and <em>Subtitle</em>, which you’ll do now.</p>
<p>Define a parameter named <em>article</em> that’s a <em>Custom</em> data type and a <em>publishDate</em> that’s of type <em>String</em>.</p>
<p>Then, in the <em>Shortcut Types</em> section, click the plus button to add one type that includes both the <em>article</em> and <em>publishDate</em> arguments as its parameters.</p>
<p>Next, set up the <em>Title</em> and <em>Subtitle</em> for the shortcut.</p>
<p>Make the title <em>Post “${article}”</em> and the subtitle <em>on ${publishDate}</em>. If you don’t copy and paste, make sure to let Xcode autocomplete <em>article</em> and <em>publishDate</em>.</p>
<p>Finally, make sure <em>Supports background execution</em> is checked so you aren’t forced to leave the Siri UI.</p>
<h3 id="toc-anchor-011">Setting Up Siri’s Responses</h3>
<p>Click on <em>Response</em> so you can define how Siri will respond to the user.</p>
<p>Once again, configure your responses like this:</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse-650x428.png" alt="PostArticleResponse definition" width="650" height="428" class="aligncenter size-large bordered wp-image-209337" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Under <em>Properties</em> you can once again define the dynamic parts of what Siri will say. Add properties for <em>title</em>, <em>publishDate</em> and <em>failureReason</em>; make them all strings.</p>
<p>Then, under <em>Response Templates</em>, add this template for <em>failure</em>:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-type">Sorry</span>, but <span class="hljs-type">I</span> couldn't post your article. ${failureReason}<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>And this template for success:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-type">Your</span> article <span class="hljs-string">"${title}"</span> was successfully posted on ${publishDate}. <span class="hljs-type">Nice</span> work!<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<h3 id="toc-anchor-012">Adding a Siri Extension</h3>
<p>To pull off the trick of being able to stay in Siri’s UI without launching your app, you need to create an <em>Intents Extension</em> with code that can manage the interaction.</p>
<p>Click on the project file in the upper left-hand corner, then find the plus symbol that allows you to add a new target.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget-650x428.png" alt="Add Intents target" width="650" height="428" class="aligncenter size-large bordered wp-image-209338" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Now, find the <em>Intents Extension</em> target; you can search for it in the Filter search bar.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension-650x428.png" alt="select Intents extension" width="650" height="428" class="aligncenter size-large bordered wp-image-209339" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Then, name your intents extension <em>WritingIntents</em>, set <em>Starting Point</em> to <em>None</em>, and uncheck the <em>Include UI Extension</em> option.</p>
<p>Finally, click the <em>Finish</em> button to create your extension. Build and run to make sure things still work.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/screenshot.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200772" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/screenshot.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/screenshot-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/screenshot-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<div class="note">
<em>Note</em>: When Xcode offers to activate the <em>WritingIntents</em> scheme, click <em>Cancel</em>.</div>
<p>Nothing new to see, but now you’re ready to use your custom intents!</p>
<p>There are two quick things you’ll need to do before moving on. </p>
<p>First, make sure <em>ArticleIntents.intentdefinition</em> is visible to the extension.</p>
<p>Open the file, then look in the File inspector. Make sure its <em>Target Membership</em> includes the app, framework and extension. Also, make sure to change the code generation option to <em>No Generated Classes</em> for the app and extension targets since this code should live in the framework.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/targets.png" alt="" width="676" height="162" class="aligncenter size-full bordered wp-image-200775" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/targets.png 676w, https://koenig-media.raywenderlich.com/uploads/2018/08/targets-480x115.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/08/targets-650x156.png 650w" sizes="(max-width: 676px) 100vw, 676px"></p>
<p>Next, your extension and main app need to share an app group. Since articles are saved to and loaded from disk, this is the only way both targets can share the same area on the file system.</p>
<p>Click on the project file in the Project navigator, make sure you have <em>TheBurgeoningWriter</em> selected and go to the <em>Capabilities</em> tab.</p>
<p>Switch the <em>App Groups</em> capability to <em>ON</em>, and name the group <em>group.&lt;your-bundle-id&gt;</em>.  </p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup-650x428.png" alt="enable app group on main project" width="650" height="428" class="aligncenter size-large bordered wp-image-209340" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Next, select the <em>WritingIntents</em> extension and do the same thing. This time, the group should exist so you can check simply the box.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2-650x428.png" alt="enable app group on intents extension" width="650" height="428" class="aligncenter size-large bordered wp-image-209341" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>Finally, open <em>ArticleManager.swift</em> and locate the declaration for <code>groupIdentifier</code>. Change its value to match your newly defined app group name.</p>
<div class="note">
<em>Note</em>: The previous articles you’ve entered will no longer appear in the app after this change. This is expected since they’re stored in a different spot in the file system.</div>
<h3 id="toc-anchor-013">Donating Post Article Intents</h3>
<p>Now that you’ve defined an intent for posting articles, it’s time to create and donate one at the appropriate time.</p>
<p>Once again, head to <em>Article.swift</em> so you can add a method for generating “post” intents for new articles.</p>
<p>Below your definition of <code>newArticleShortcut(thumbnail:)</code>, add the following method definition:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">public</span> <span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">donatePublishIntent</span><span class="hljs-params">()</span></span> {

}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<p>This method creates and donates the intent all at once since you don’t need to deal with adding intents to a view controller.</p>
<p>Now, create the intent object and assign an article and publish date to it:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> intent = <span class="hljs-type">PostArticleIntent</span>()
intent.article = <span class="hljs-type">INObject</span>(identifier: <span class="hljs-keyword">self</span>.title, display: <span class="hljs-keyword">self</span>.title)
intent.publishDate = formattedDate()
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>If you’re wondering where this class came from, Xcode generated it for you when you created the <em>ArticleIntents.intentdefinition</em> file.</p>
<p>An <code>INObject</code> is a generic object you can use to add custom types to your intent. In this case, you’re just giving it an identifier and the display value of the article’s title.</p>
<p>Next, create an interaction from this intent:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">let</span> interaction = <span class="hljs-type">INInteraction</span>(intent: intent, response: <span class="hljs-literal">nil</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>When using a custom intent, the thing that you’ll end up donating to the system is an interaction like this one.</p>
<p>Finally, do the donation by calling <code>donate(_:)</code> on the interaction:</p>
<pre lang="swift" class="language-swift hljs">interaction.donate(completion: <span class="hljs-literal">nil</span>)
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Here, you’re donating your interaction without worrying about the completion block. You can, of course, add error handling or whatever else you want to this completion block.</p>
<p>You must complete one last “secret handshake” step: You must tell iOS exactly what intents your app supports. To do this, click on the project file in the Project navigator. Select the <em>WritingIntents</em> target and click the <em>Info</em> tab. <em>Option-click</em> the disclosure triangle next to the <em>NSExtension</em> key to open the entire key. Hover over <em>IntentsSupported</em> to reveal the plus button and click it once. Set the value of the newly added item to <em>PostArticleIntent</em>.</p>
<p><a href="https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents.png"><img src="https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents-650x428.png" alt="list supported intents" width="650" height="428" class="aligncenter size-large bordered wp-image-209342" srcset="https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents-650x428.png 650w, https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents-480x316.png 480w, https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents.png 1400w" sizes="(max-width: 650px) 100vw, 650px"></a></p>
<p>That’s it! That’s all there is to donating an intent-based shortcut to the system.</p>
<p>Now that you’ve got the method defined, go to <em>NewArticleViewController.swift</em> and find <code>saveWasTapped()</code>. Since you want the system to prompt users to post articles that they’ve saved for later, this is where you’ll make it happen.</p>
<p>Add this line to donate the intent below the comment in that method:</p>
<pre lang="swift" class="language-swift hljs">article.donatePublishIntent()
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Now that you’re donating, build and run the app. Then, create and save a new article. After you’ve done so, go to Spotlight search, and you should see a new donation that looks something like this.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/publishIntents.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200773" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/publishIntents.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/publishIntents-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/publishIntents-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<h3 id="toc-anchor-014">Handling Intents-Based Shortcuts</h3>
<p>Like before, you now have to think about handling this shortcut when the user has used it.</p>
<p>This time, the extension you created will be responsible for handling things. </p>
<p>First, add a new <em>Swift</em> file in the <em>WritingIntents</em> folder named <em>PostArticleIntentHandler.swift</em>.</p>
<p>Replace <code>import Foundation</code> with this:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">import</span> UIKit
<span class="hljs-keyword">import</span> ArticleKit

<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">PostArticleIntentHandler</span>: <span class="hljs-title">NSObject</span>, <span class="hljs-title">PostArticleIntentHandling</span> </span>{
<span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">confirm</span><span class="hljs-params">(intent: PostArticleIntent,
completion: @escaping <span class="hljs-params">(PostArticleIntentResponse)</span></span></span> -&gt; <span class="hljs-type">Void</span>) {

}

<span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">handle</span><span class="hljs-params">(intent: PostArticleIntent,
completion: @escaping <span class="hljs-params">(PostArticleIntentResponse)</span></span></span> -&gt; <span class="hljs-type">Void</span>) {

}
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<p>Here, you’re creating the class that handles responding to interactions involving your post article intent.</p>
<p>Conforming to the <code>PostArticleIntentHandling</code> protocol means that you need to implement one method involving the confirmation step and one method for handling the intent after the user has confirmed.</p>
<p>Next, add the following code to <code>confirm(intent:completion:)</code>:</p>
<pre lang="swift" class="language-swift hljs">completion(<span class="hljs-type">PostArticleIntentResponse</span>(code: <span class="hljs-type">PostArticleIntentResponseCode</span>.ready,
                                     userActivity: <span class="hljs-literal">nil</span>))
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>This indicates that if the user taps confirm, then the extension is ready to take on the intent.</p>
<p>Next, you’ll implement <code>handle(intent:completion:)</code>.</p>
<p>This is where the real choices come into play. Since the user is trying to post an article, you should only respond with a success message if it works.</p>
<p>First, add this guard statement for when the article they chose isn’t found:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">guard</span> <span class="hljs-keyword">let</span> title = intent.article?.identifier,
    <span class="hljs-keyword">let</span> article = <span class="hljs-type">ArticleManager</span>.findArticle(with: title) <span class="hljs-keyword">else</span> {
        completion(<span class="hljs-type">PostArticleIntentResponse</span>
          .failure(failureReason: <span class="hljs-string">"Your article was not found."</span>))
        <span class="hljs-keyword">return</span>
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>This calls the completion block with a <em>failure</em> intent response. Its only argument is called <code>failureReason</code> because the failure response template you created earlier has the <code>failureReason</code> variable in the template.</p>
<p>Next, add a guard for when this article has already been published:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">guard</span> !article.published <span class="hljs-keyword">else</span> {
    completion(<span class="hljs-type">PostArticleIntentResponse</span>
      .failure(failureReason: <span class="hljs-string">"This article has already been published."</span>))
    <span class="hljs-keyword">return</span>
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Finally, for the success case, you’ll publish the article and call completion with the success response. This includes the article’s title and the date on which it was published:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-type">ArticleManager</span>.publish(article)
completion(<span class="hljs-type">PostArticleIntentResponse</span>
  .success(title: article.title, publishDate: article.formattedDate()))
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Now that you have your intent handler set up, you have to make sure it gets used.</p>
<p>Open <em>IntentHandler.swift</em> and replace the existing <code>handler(for:)</code> with the following to tell the system to use the handler you just wrote:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">override</span> <span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">handler</span><span class="hljs-params">(<span class="hljs-keyword">for</span> intent: INIntent)</span></span> -&gt; <span class="hljs-type">Any</span> {
  <span class="hljs-keyword">return</span> <span class="hljs-type">PostArticleIntentHandler</span>()
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>Next, open <em>AppDelegate.swift</em> and find <code>application(_:continue:restorationHandler:)</code>.</p>
<p>Something you might not expect is that even though you have your own handler for dealing with this shortcut, the continue user activity callback in the app delegate is still called.</p>
<p>To block the method from taking users out of Siri and to the new article view, add the following guard:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-keyword">guard</span> userActivity.interaction == <span class="hljs-literal">nil</span> <span class="hljs-keyword">else</span>  {
    <span class="hljs-type">ArticleManager</span>.loadArticles()
    rootVC.viewWillAppear(<span class="hljs-literal">false</span>)

    <span class="hljs-keyword">return</span> <span class="hljs-literal">false</span>

}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>

<p>If the activity has an interaction attached, that means its the “publish” shortcut, and you need to load the articles and make sure the feed view controller reloads.</p>
<p>Build and run, and then write a new article to donate one of these shortcuts.</p>
<div class="note">
<em>Note</em>: You can safely ignore the warning about linking against a dylib which is not safe for use in application extensions.</div>
<p>Next, go into Settings and make a shortcut for it with a title; something like “Post my last article” works perfectly.</p>
<p>After that, start Siri and use your shortcut; Siri will post the article for you and respond with a custom response informing you of the title and publication date.</p>
<p><img src="https://koenig-media.raywenderlich.com/uploads/2018/08/IntentsSuccess.jpeg" alt="" width="250" class="aligncenter size-full bordered wp-image-200785" srcset="https://koenig-media.raywenderlich.com/uploads/2018/08/IntentsSuccess.jpeg 1242w, https://koenig-media.raywenderlich.com/uploads/2018/08/IntentsSuccess-180x320.jpeg 180w, https://koenig-media.raywenderlich.com/uploads/2018/08/IntentsSuccess-281x500.jpeg 281w" sizes="(max-width: 1242px) 100vw, 1242px"></p>
<h3 id="toc-anchor-015">Wrapping Up</h3>
<p>The final thing you need to worry about is deleting intents from the system. Let’s say a user has deleted the only article they wrote. If Siri prompts them to publish this article, that means the system remembers information that they wanted to delete.</p>
<p>Since this goes against Apple’s strict respect for user privacy, it’s your job to remove activities and intents that were deleted.</p>
<p>Go to <em>ArticleFeedViewController.swift</em> and scroll to the bottom of the file. </p>
<p>Then, add the following method call to the bottom of <code>remove(article:indexPath:)</code>:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-type">INInteraction</span>.delete(with: article.title) { <span class="hljs-number">_</span> <span class="hljs-keyword">in</span>
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>The completion block allows you to react to deletion errors however you see fit.</p>
<p>Since the new article shortcut doesn’t contain any user data, it isn’t strictly necessary to remove it.</p>
<p>Finally, open <em>Layouts.swift</em> and find the <code>UITableViewDataSource</code> extension for <code>ArticleFeedViewController</code>. Add the following at the end of the extension to enable deleting articles:</p>
<pre lang="swift" class="language-swift hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">tableView</span><span class="hljs-params">(<span class="hljs-number">_</span> tableView: UITableView,
                 commit editingStyle: UITableViewCell.EditingStyle,
                 forRowAt indexPath: IndexPath)</span></span> {
  <span class="hljs-keyword">if</span> editingStyle == .delete {
    <span class="hljs-keyword">let</span> article = articles[indexPath.row]
    remove(article: article, at: indexPath)
    <span class="hljs-keyword">if</span> articles.<span class="hljs-built_in">count</span> == <span class="hljs-number">0</span> {
      <span class="hljs-type">NSUserActivity</span>.deleteSavedUserActivities(withPersistentIdentifiers: 
        [<span class="hljs-type">NSUserActivityPersistentIdentifier</span>(kNewArticleActivityType)]) {
          <span class="hljs-built_in">print</span>(<span class="hljs-string">"Successfully deleted 'New Article' activity."</span>)
      }
    }
  }
}
<button class="o-button-copy"></button><button class="o-button-code o-button-code--light"></button></pre>
<p>If you want, you can use <code>NSUserActivity</code>‘s class method <code>deleteSavedUserActivities(withPersistentIdentifiers:completionHandler:)</code> to remove all of the activities that were donated with a single identifier.</p>
<h2 id="toc-anchor-016">Where to Go From Here?</h2>
<p>You’ve worked through a lot, but there’s still a lot to learn. You can download the completed version of the project using the <b>Download Materials</b> button at the top or bottom of this tutorial. Be sure you update your bundle id and app group id before you try to run it.</p>
<p>If you want to learn more about Shortcuts, check out the two WWDC videos from 2018. The <a href="https://developer.apple.com/videos/play/wwdc2018/211" target="_blank" rel="noopener">first presentation</a> covers a lot of the same material as this tutorial and is a good refresher to solidify the big ideas you learned here. The <a href="https://developer.apple.com/videos/play/wwdc2018/214/" target="_blank" rel="noopener">second</a> goes more into best practices.</p>
<p>As always, we hope you enjoyed the tutorial. Let us know if you have any questions down in the comments!</p>

        <div class="l-margin-24 c-written-tutorial__content-footer">
          <div class="c-written-tutorial__content-tags">
              <a class="o-tag" href="/library?category_ids%5B%5D=152&amp;domain_ids%5B%5D=1&amp;sort_order=released_at">Other Core APIs</a>

<a class="o-tag" href="/library?domain_ids%5B%5D=1&amp;sort_order=released_at">iOS &amp; Swift Tutorials</a>

          </div>
          <div class="c-written-tutorial__content-share">
            <button class="o-button--share"><i class="o-button__icon o-button__icon--large o-button__icon--medium-grey"><svg class="l-button__svg-facebook-share o-button__svg--white"><use xlink:href="#facebook-icon--white"></use></svg></i></button>

            <button class="o-button--share"><i class="o-button__icon o-button__icon--large o-button__icon--medium-grey"><svg class="l-button__svg-twitter-share o-button__svg--white"><use xlink:href="#twitter-icon--white"></use></svg></i></button>

            <button class="o-button--bookmark"><span class="o-button__wrapper"><i class="o-button__icon"><svg class="o-button__svg o-button__svg--medium-grey l-button__svg-bookmark-icon"><use xlink:href="#bookmark"></use></svg></i></span></button>

          </div>
        </div>
        <div class="c-written-tutorial__content-buttons l-flex-justify-center l-margin-60">
            <a class="o-button--green o-button--files" data-materials-download-button-content-id="6462" data-event-action="downloadFiles" data-event-category="article_all_downloadProject" href="https://koenig-media.raywenderlich.com/uploads/2018/12/TheBurgeoningWriter.zip">

  <i class="o-button__icon--left o-button__icon--white">
    <svg class="l-button__svg-arrow-90 o-button__svg o-button__svg--green"><use xlink:href="#arrow-right"></use></svg>
  </i>
  <span class="o-button__label"><span class="u-hide-mobile">Download</span> Materials</span>
</a>
            <button class="o-button--dark l-margin-sides-8"><span class="o-button__wrapper"><i class="o-button__icon--left o-button__icon--input o-button__icon--left"><svg class="o-button__svg l-button__svg-checkmark o-button__svg--green"><use xlink:href="#"></use></svg></i> <span class="o-button__label">Mark Complete</span></span></button>

        </div>
        <div class="l-border-top l-margin-36 l-article-rating-footer" id="c-rate">
            <div id="c-add-rating" class="c-add-rating l-block--card-medium l-block l-padding-30"><div class="l-text-align-center"><h3 class="l-font-header l-font-17 l-font-bold">Add a rating for this content</h3> <div class="l-margin-15"><span data-v-5ead5c60=""><span data-v-5ead5c60="" class="o-icon-button o-icon-button--small c-rate__star"><i data-v-5ead5c60=""><svg data-v-5ead5c60="" class="o-button__svg--white l-button__svg-star"><use data-v-5ead5c60="" xlink:href="#star"></use></svg></i></span></span><span data-v-5ead5c60=""><span data-v-5ead5c60="" class="o-icon-button o-icon-button--small c-rate__star"><i data-v-5ead5c60=""><svg data-v-5ead5c60="" class="o-button__svg--white l-button__svg-star"><use data-v-5ead5c60="" xlink:href="#star"></use></svg></i></span></span><span data-v-5ead5c60=""><span data-v-5ead5c60="" class="o-icon-button o-icon-button--small c-rate__star"><i data-v-5ead5c60=""><svg data-v-5ead5c60="" class="o-button__svg--white l-button__svg-star"><use data-v-5ead5c60="" xlink:href="#star"></use></svg></i></span></span><span data-v-5ead5c60=""><span data-v-5ead5c60="" class="o-icon-button o-icon-button--small c-rate__star"><i data-v-5ead5c60=""><svg data-v-5ead5c60="" class="o-button__svg--white l-button__svg-star"><use data-v-5ead5c60="" xlink:href="#star"></use></svg></i></span></span><span data-v-5ead5c60=""><span data-v-5ead5c60="" class="o-icon-button o-icon-button--small c-rate__star"><i data-v-5ead5c60=""><svg data-v-5ead5c60="" class="o-button__svg--white l-button__svg-star"><use data-v-5ead5c60="" xlink:href="#star"></use></svg></i></span></span></div></div> <!----></div>

        </div>
      </div>If you’ve had an iPhone for any length of time, you’ve likely interacted with Siri. When Siri was [first announced](https://www.youtube.com/watch?v=agzItTz35QQ) in 2011, its ability to understand context and meaning, regardless of the specific combination of words used, was groundbreaking.

Unfortunately, Siri integration was limited to Apple’s own apps until the release of _SiriKit_ in 2016. Even then, the types of things you could do with Siri were limited to a particular set of domains.

With the release of _Siri Shortcuts_ in iOS 12, this is no longer the case. Now, you can create custom intents to represent any domain, and you can expose your app’s services directly to Siri.

In this tutorial, you’ll learn how to use these new shortcuts APIs to integrate Siri into a writing app.

## Getting Started

To get started, use the _Download Materials_ button at the top or bottom of this tutorial to download the starter project.

Once downloaded, double-click _TheBurgeoningWriter.xcodeproj_ to open the project in Xcode.

_Note_: If possible, you should use a physical device to follow along with this tutorial. Although the Simulator works, it behaves differently with a few things.

Set the bundle ID to something unique to you (Apple recommends using a reverse DNS name such as com.razeware.TheBurgeoningWriter). Then, run the app, and you’ll see a home screen that shows all of the written articles. From here, you can add new articles and publish the drafts you’ve previously saved.

The big idea here is to write an article, sit on it for a little bit, and then publish it later — provided you’re still happy with it.

Ready to begin? Great!

### Adding Shortcuts to an App

The first thing to consider is which features of your app are appropriate for turning into shortcuts.

Ideally, you should create shortcuts for actions your user can perform; preferably, something they’ll likely do repeatedly. Once you’ve decided to set up a shortcut, there are two ways to create it:

1.  _NSUserActivity_: User activities are part of an existing API that allows you to expose certain things a user can do for app hand-off and Spotlight searches. The thing to remember here is that this option is only useful when you want the user to go from Siri into your app to complete a task.
2.  _Custom Intents_: Creating a custom intent is the true power of shortcuts. With an intent, you can communicate with your user via Siri without ever having to open your app.

## Making a Shortcut for Writing New Articles

Your first shortcut is one that lets a user go straight to the new article screen. This is the perfect candidate for creating a shortcut based on an `NSUserActivity` object, because it’ll take the user from Siri into your app.

Your goal is to donate one of these activities to the system every time your user performs that action. You’ll do so by adding a new method that allows you to generate these activity objects.

Open _Article.swift_ and, at the top of the file under the imports, add the following constant string definition:

public let kNewArticleActivityType = "com.razeware.NewArticle"

This is the identifier you’ll use to determine if you’re dealing with a “new article” shortcut. A good rule of thumb is to use the reverse DNS convention when choosing an identifier for your shortcut.

Next, below the properties, add the following method definition:

public static func newArticleShortcut(thumbnail: UIImage?) -\> NSUserActivity {
let activity = NSUserActivity(activityType: kNewArticleActivityType)
activity.persistentIdentifier =
NSUserActivityPersistentIdentifier(kNewArticleActivityType)

return activity
}

Here, you’re creating an activity object with the correct identifier and returning it. The `persistentIdentifier` is what connects all of these shortcuts as one activity.

For your activity to be useful, you have to do some configuration.

Add the following two lines before the `return`:

activity.isEligibleForSearch = true
activity.isEligibleForPrediction = true

First, you set `isEligibleForSearch` to `true`. This allows users to search for this feature in Spotlight. You then set `isEligibleForPrediction` to `true` so prediction works. Setting this to `true` allows Siri to look at the activity and suggest it to your users in the future. It’s also what allows the activity to be turned into a Shortcut later.

Next, you’ll set the properties that affect how your Shortcut looks to users.

Define a local attributes property. Add it below the previously pasted lines:

let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

Set your attributes by adding the following lines:

activity.title = "Write a new article"
attributes.contentDescription = "Get those creative juices flowing!"
attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)

This sets the title, subtitle and thumbnail image you’ll see on the suggestion notification.

Stepping back for a moment, it’s important to remember that Siri exposes this feature in two separate ways:

- First, Siri learns to predict what your users might want to do in the form of suggestions that pop up in _Notification Center_ and _Spotlight Search_.
- Second, your users can turn these activities into voice-based shortcuts.

For the last bit of configuration, add the suggested phrase users should consider when making a shortcut for this activity:

activity.suggestedInvocationPhrase = "Time to write!"

The chosen phrase should be something that’s short and easy to remember. It should also not include the phrase “Hey, Siri” because the user might have already triggered Siri’s interface that way.

Finally, assign the attributes object to the activity object:

activity.contentAttributeSet = attributes

Now that you can grab user activity objects from an `Article`, it’s time to use them.

### Using the Activity Object

Open _ArticleFeedViewController.swift_ and locate `newArticleWasTapped()`.

Below the comment, add the following lines:

//1
let activity = Article.newArticleShortcut(thumbnail: UIImage(named: "notePad"))
vc.userActivity = activity

//2
activity.becomeCurrent()

1.  First, you create an activity object. Then, you attach it to the view controller that’ll be on screen.
2.  Next, you call `becomeCurrent()` to officially become the “current” activity. This is the method that registers your activity with the system.

Congratulations, you’re now successfully donating this activity to Siri.

Build and run. Then, go to the new article screen and back to the home screen a few times.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/NewBackAndForth.gif)

You won’t see anything too interesting in the app, but each time you perform that action, you’re donating an activity to the system.

To verify, pull down on the home screen to go to search. Then, type “write”, and you should see the “Write a new article” action come up.

![](https://koenig-media.raywenderlich.com/uploads/2018/07/SearchForWriting.png)

### Continuing a User Activity

Tap on the “Write a new article” result in your search. You’ll be taken to your app’s home screen.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/basic-annoyed-1-510x510.png)

Your feature may be exposed to the system, but your app isn’t doing anything when the system tells it the user would like to use the feature.

To react to this request, open _AppDelegate.swift_, and at the bottom of the class, add the following method definition:

func application(
\_ application: UIApplication,
continue userActivity: NSUserActivity,
restorationHandler: @escaping (\[UIUserActivityRestoring\]?) -\> Void
) -\> Bool {
return true
}

Inside the method and before the `return` statement, create the New Article view controller and push it onto the nav stack:

let vc = NewArticleViewController()
nav?.pushViewController(vc, animated: false)

Build and run again. When you search for this feature and tap on it, your app takes you directly to the New Article screen.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/SuccessfulShortcut.gif)

### Developer Settings for Working With Siri

All you’ve done so far is accessed your feature from Spotlight. This isn’t anything new, and it would work even if Siri weren’t involved since you made your activity eligible for search.

To prove that Siri can start suggesting this action, you’ll need to go to the Settings app and enable a few options.

Open _Settings_ and find the _Developer_ option. Scroll towards the bottom and you’ll see a section named _SHORTCUTS TESTING_.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/ShortcutsTestingOff.png)

Turning on the _Display Recent Shortcuts_ option means that recently donated shortcuts will show up in _Spotlight Search_ instead of Siri’s current predictions.

Similarly, _Display Donations on Lock Screen_ always shows your recent donations as a notification on your lock screen.

Turn on both of the options so you can always see what shortcuts your app has donated most recently.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/donationsOnLockscreen.png)

Now that you know how to see what Siri’s suggestions look like, it’s time to turn these activities into full-blown shortcuts!

## Turning User Activities Into Shortcuts

When a user wants to turn one of these activities into a shortcut, they can do so from the Settings app. As the developer, there’s nothing more you need to do.

To test it out: On your device, open _Settings > Siri & Search_.

The first section shows a list of shortcuts donated by the different apps on your phone. You’ll see the “Write a new article” shortcut in this list; if you don’t, tap _More Shortcuts_ to see more.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/MakeShortcuts.jpeg)

To add a shortcut for this action, tap the action, and you’ll be taken to the shortcut creation screen.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/AddToSiri.jpeg)

Here, you can see that suggested invocation phrase you added earlier.

Tap the red circle at the bottom. When prompted, say to Siri, “Time to write”. After Siri figures out what you said, tap _Done_ to finalize your shortcut.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/Done.jpeg)

Now, your shortcut is listed along with any other shortcuts you’ve created.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/myShortcuts.jpeg)

## Adding Shortcuts To Siri From Your App

This is all well and good, but can you expect users to muck around in the Settings app to add a shortcut for your app? Nope! Not at all.

Fortunately, you can prompt your users to do this straight from your app!

Open _NewArticleViewController.swift_ and you’ll see an empty definition for `addNewArticleShortcutWasTapped()`.

This is the method that gets called when the blue “Add Shortcut to Siri” button is tapped.

The _IntentsUI_ framework provides a special view controller that you can initialize with a shortcut. You can then present this view controller to show the same UI you just saw in the Settings app.

Add the following two lines to initialize the shortcut:

let newArticleActivity = Article
.newArticleShortcut(thumbnail: UIImage(named: "notePad.jpg"))
let shortcut = INShortcut(userActivity: newArticleActivity)

Next, create the view controller, set the delegate and present the view:

let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
vc.delegate = self

present(vc, animated: true, completion: nil)

At this point, Xcode complains that this class isn’t fit to be the delegate of that view controller. You’ll need to fix this.

Add the following extension at the bottom of the file:

extension NewArticleViewController: INUIAddVoiceShortcutViewControllerDelegate {
}

Then, conform to the `INUIAddVoiceShortcutViewControllerDelegate` protocol by adding the method for when the user successfully creates a shortcut:

func addVoiceShortcutViewController(
\_ controller: INUIAddVoiceShortcutViewController,
didFinishWith voiceShortcut: INVoiceShortcut?,
error: Error?
) {
}

Also, add the method for when the user taps the _Cancel_ button:

func addVoiceShortcutViewControllerDidCancel(
\_ controller: INUIAddVoiceShortcutViewController) {
}

Next, you need to dismiss the Siri view controller when these methods are called.

Add the following line to both methods:

dismiss(animated: true, completion: nil)

Build and run to try it out! Go to the New Article view and tap _Add Shortcut to Siri_.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/InAppSiri.gif)

You’ll see a view controller that looks a lot like the view you see when you go to set up shortcuts in the Settings app. With this in place, your users won’t have excuses for not utilizing your app’s full potential! :\]

## Publishing Articles with Siri

Next, you want to add the ability to publish articles you’ve written directly from Siri. The big difference here is that instead of Siri opening your app, everything will happen in-line, directly from the Siri UI.

For this shortcut, you’ll create a custom _Intent_ to define the back and forth between Siri, your users and your app.

### Defining a Custom Writing Intent

In the Project navigator, locate the _ArticleKit_ folder and click on it to highlight it.

Then, press _Command + N_ to create a new file.

In the filter search box, type _Intent_ and you’ll see _SiriKit Intent Definition File_.

[![add intent definition file](https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/11/Screen-Shot-2018-12-01-at-6.31.45-PM.png)

Click _Next_, then name your file _ArticleIntents.intentdefinition_.

Now it’s time to create an intent for posting articles you’ve written.

Go to the bottom of the section that reads _No Intents_ and click the plus button to add a new intent definition.

[![add new intent](https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents-650x429.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/emptyIntents.png)

Name it _PostArticle_, and then configure your intent based on these settings (described after the picture):

[![PostArticleIntent definition](https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleIntent-option2.png)

This screen is for configuring the information that the publish intent needs to work.

The options in the _Custom Intent_ section define what type of intent it is and can affect how Siri talks about the action. Telling Siri that this is a _Post_ type action lets the system know that you’re sharing some bit of content somewhere:

1.  _Category_: Post
2.  _Title_: Post Article
3.  _Description_: Post the last article
4.  _Default Image_: Select one of the existing images in the project.
5.  _Confirmation_: Check this box since you want to ask the user to verify that they’re really ready to publish this article.

The _Parameters_ section is where you define any dynamic properties used in the _Title_ and _Subtitle_, which you’ll do now.

Define a parameter named _article_ that’s a _Custom_ data type and a _publishDate_ that’s of type _String_.

Then, in the _Shortcut Types_ section, click the plus button to add one type that includes both the _article_ and _publishDate_ arguments as its parameters.

Next, set up the _Title_ and _Subtitle_ for the shortcut.

Make the title _Post “${article}”_ and the subtitle _on ${publishDate}_. If you don’t copy and paste, make sure to let Xcode autocomplete _article_ and _publishDate_.

Finally, make sure _Supports background execution_ is checked so you aren’t forced to leave the Siri UI.

### Setting Up Siri’s Responses

Click on _Response_ so you can define how Siri will respond to the user.

Once again, configure your responses like this:

[![PostArticleResponse definition](https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/PostArticleResponse.png)

Under _Properties_ you can once again define the dynamic parts of what Siri will say. Add properties for _title_, _publishDate_ and _failureReason_; make them all strings.

Then, under _Response Templates_, add this template for _failure_:

Sorry, but I couldn't post your article. ${failureReason}

And this template for success:

Your article "${title}" was successfully posted on ${publishDate}. Nice work!

### Adding a Siri Extension

To pull off the trick of being able to stay in Siri’s UI without launching your app, you need to create an _Intents Extension_ with code that can manage the interaction.

Click on the project file in the upper left-hand corner, then find the plus symbol that allows you to add a new target.

[![Add Intents target](https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/AddTarget.png)

Now, find the _Intents Extension_ target; you can search for it in the Filter search bar.

[![select Intents extension](https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/IntentsExtension.png)

Then, name your intents extension _WritingIntents_, set _Starting Point_ to _None_, and uncheck the _Include UI Extension_ option.

Finally, click the _Finish_ button to create your extension. Build and run to make sure things still work.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/screenshot.jpeg)

_Note_: When Xcode offers to activate the _WritingIntents_ scheme, click _Cancel_.

Nothing new to see, but now you’re ready to use your custom intents!

There are two quick things you’ll need to do before moving on.

First, make sure _ArticleIntents.intentdefinition_ is visible to the extension.

Open the file, then look in the File inspector. Make sure its _Target Membership_ includes the app, framework and extension. Also, make sure to change the code generation option to _No Generated Classes_ for the app and extension targets since this code should live in the framework.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/targets.png)

Next, your extension and main app need to share an app group. Since articles are saved to and loaded from disk, this is the only way both targets can share the same area on the file system.

Click on the project file in the Project navigator, make sure you have _TheBurgeoningWriter_ selected and go to the _Capabilities_ tab.

Switch the _App Groups_ capability to _ON_, and name the group _group.<your-bundle-id>_.

[![enable app group on main project](https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup.png)

Next, select the _WritingIntents_ extension and do the same thing. This time, the group should exist so you can check simply the box.

[![enable app group on intents extension](https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/appgroup2.png)

Finally, open _ArticleManager.swift_ and locate the declaration for `groupIdentifier`. Change its value to match your newly defined app group name.

_Note_: The previous articles you’ve entered will no longer appear in the app after this change. This is expected since they’re stored in a different spot in the file system.

### Donating Post Article Intents

Now that you’ve defined an intent for posting articles, it’s time to create and donate one at the appropriate time.

Once again, head to _Article.swift_ so you can add a method for generating “post” intents for new articles.

Below your definition of `newArticleShortcut(thumbnail:)`, add the following method definition:

public func donatePublishIntent() {

}

This method creates and donates the intent all at once since you don’t need to deal with adding intents to a view controller.

Now, create the intent object and assign an article and publish date to it:

let intent = PostArticleIntent()
intent.article = INObject(identifier: self.title, display: self.title)
intent.publishDate = formattedDate()

If you’re wondering where this class came from, Xcode generated it for you when you created the _ArticleIntents.intentdefinition_ file.

An `INObject` is a generic object you can use to add custom types to your intent. In this case, you’re just giving it an identifier and the display value of the article’s title.

Next, create an interaction from this intent:

let interaction = INInteraction(intent: intent, response: nil)

When using a custom intent, the thing that you’ll end up donating to the system is an interaction like this one.

Finally, do the donation by calling `donate(_:)` on the interaction:

interaction.donate(completion: nil)

Here, you’re donating your interaction without worrying about the completion block. You can, of course, add error handling or whatever else you want to this completion block.

You must complete one last “secret handshake” step: You must tell iOS exactly what intents your app supports. To do this, click on the project file in the Project navigator. Select the _WritingIntents_ target and click the _Info_ tab. _Option-click_ the disclosure triangle next to the _NSExtension_ key to open the entire key. Hover over _IntentsSupported_ to reveal the plus button and click it once. Set the value of the newly added item to _PostArticleIntent_.

[![list supported intents](https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents-650x428.png)](https://koenig-media.raywenderlich.com/uploads/2018/12/Add-supported-intents.png)

That’s it! That’s all there is to donating an intent-based shortcut to the system.

Now that you’ve got the method defined, go to _NewArticleViewController.swift_ and find `saveWasTapped()`. Since you want the system to prompt users to post articles that they’ve saved for later, this is where you’ll make it happen.

Add this line to donate the intent below the comment in that method:

article.donatePublishIntent()

Now that you’re donating, build and run the app. Then, create and save a new article. After you’ve done so, go to Spotlight search, and you should see a new donation that looks something like this.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/publishIntents.jpeg)

### Handling Intents-Based Shortcuts

Like before, you now have to think about handling this shortcut when the user has used it.

This time, the extension you created will be responsible for handling things.

First, add a new _Swift_ file in the _WritingIntents_ folder named _PostArticleIntentHandler.swift_.

Replace `import Foundation` with this:

import UIKit
import ArticleKit

class PostArticleIntentHandler: NSObject, PostArticleIntentHandling {
func confirm(intent: PostArticleIntent,
completion: @escaping (PostArticleIntentResponse) -\> Void) {

}

func handle(intent: PostArticleIntent,
completion: @escaping (PostArticleIntentResponse) -\> Void) {

}
}

Here, you’re creating the class that handles responding to interactions involving your post article intent.

Conforming to the `PostArticleIntentHandling` protocol means that you need to implement one method involving the confirmation step and one method for handling the intent after the user has confirmed.

Next, add the following code to `confirm(intent:completion:)`:

completion(PostArticleIntentResponse(code: PostArticleIntentResponseCode.ready,
userActivity: nil))

This indicates that if the user taps confirm, then the extension is ready to take on the intent.

Next, you’ll implement `handle(intent:completion:)`.

This is where the real choices come into play. Since the user is trying to post an article, you should only respond with a success message if it works.

First, add this guard statement for when the article they chose isn’t found:

guard let title = intent.article?.identifier,
let article = ArticleManager.findArticle(with: title) else {
completion(PostArticleIntentResponse
.failure(failureReason: "Your article was not found."))
return
}

This calls the completion block with a _failure_ intent response. Its only argument is called `failureReason` because the failure response template you created earlier has the `failureReason` variable in the template.

Next, add a guard for when this article has already been published:

guard !article.published else {
completion(PostArticleIntentResponse
.failure(failureReason: "This article has already been published."))
return
}

Finally, for the success case, you’ll publish the article and call completion with the success response. This includes the article’s title and the date on which it was published:

ArticleManager.publish(article)
completion(PostArticleIntentResponse
.success(title: article.title, publishDate: article.formattedDate()))

Now that you have your intent handler set up, you have to make sure it gets used.

Open _IntentHandler.swift_ and replace the existing `handler(for:)` with the following to tell the system to use the handler you just wrote:

override func handler(for intent: INIntent) -\> Any {
return PostArticleIntentHandler()
}

Next, open _AppDelegate.swift_ and find `application(_:continue:restorationHandler:)`.

Something you might not expect is that even though you have your own handler for dealing with this shortcut, the continue user activity callback in the app delegate is still called.

To block the method from taking users out of Siri and to the new article view, add the following guard:

guard userActivity.interaction == nil else {
ArticleManager.loadArticles()
rootVC.viewWillAppear(false)

    return false

}

If the activity has an interaction attached, that means its the “publish” shortcut, and you need to load the articles and make sure the feed view controller reloads.

Build and run, and then write a new article to donate one of these shortcuts.

_Note_: You can safely ignore the warning about linking against a dylib which is not safe for use in application extensions.

Next, go into Settings and make a shortcut for it with a title; something like “Post my last article” works perfectly.

After that, start Siri and use your shortcut; Siri will post the article for you and respond with a custom response informing you of the title and publication date.

![](https://koenig-media.raywenderlich.com/uploads/2018/08/IntentsSuccess.jpeg)

### Wrapping Up

The final thing you need to worry about is deleting intents from the system. Let’s say a user has deleted the only article they wrote. If Siri prompts them to publish this article, that means the system remembers information that they wanted to delete.

Since this goes against Apple’s strict respect for user privacy, it’s your job to remove activities and intents that were deleted.

Go to _ArticleFeedViewController.swift_ and scroll to the bottom of the file.

Then, add the following method call to the bottom of `remove(article:indexPath:)`:

INInteraction.delete(with: article.title) { \_ in
}

The completion block allows you to react to deletion errors however you see fit.

Since the new article shortcut doesn’t contain any user data, it isn’t strictly necessary to remove it.

Finally, open _Layouts.swift_ and find the `UITableViewDataSource` extension for `ArticleFeedViewController`. Add the following at the end of the extension to enable deleting articles:

func tableView(\_ tableView: UITableView,
commit editingStyle: UITableViewCell.EditingStyle,
forRowAt indexPath: IndexPath) {
if editingStyle == .delete {
let article = articles\[indexPath.row\]
remove(article: article, at: indexPath)
if articles.count == 0 {
NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers:
\[NSUserActivityPersistentIdentifier(kNewArticleActivityType)\]) {
print("Successfully deleted 'New Article' activity.")
}
}
}
}

If you want, you can use `NSUserActivity`‘s class method `deleteSavedUserActivities(withPersistentIdentifiers:completionHandler:)` to remove all of the activities that were donated with a single identifier.

## Where to Go From Here?

You’ve worked through a lot, but there’s still a lot to learn. You can download the completed version of the project using the **Download Materials** button at the top or bottom of this tutorial. Be sure you update your bundle id and app group id before you try to run it.

If you want to learn more about Shortcuts, check out the two WWDC videos from 2018. The [first presentation](https://developer.apple.com/videos/play/wwdc2018/211) covers a lot of the same material as this tutorial and is a good refresher to solidify the big ideas you learned here. The [second](https://developer.apple.com/videos/play/wwdc2018/214/) goes more into best practices.

As always, we hope you enjoyed the tutorial. Let us know if you have any questions down in the comments!

[Other Core APIs](/library?category_ids%5B%5D=152&domain_ids%5B%5D=1&sort_order=released_at) [iOS & Swift Tutorials](/library?domain_ids%5B%5D=1&sort_order=released_at)

[Download Materials](https://koenig-media.raywenderlich.com/uploads/2018/12/TheBurgeoningWriter.zip) Mark Complete

### Add a rating for this content


