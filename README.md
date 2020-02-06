# MDT (Mobile Developer Test)
## What is it?
MDT - is a Swift project that represents a solution to a typical code challenge offered to a candidate for a position of Senior iOS Developer.
## Why was it made?
At some point I've noticed that the majority of code challenges offered by different companies have a lot in common, and it's way more effective to have a template repository and adapt it to every particular challenge rather than to start new projects from scratch.
It is also a good example to demonstrate my coding skills to anyone who is interested.
## What does it do?
MDT - is a little iOS app which:
- connects to a backend and fetches JSON with a list of products
- parses the JSON and stores received products using CoreData
- displays the products in a scrollable list, where each product has: name, brand, original price, current price (only if different from the original one), and asynchronously downloaded image
- provides a pull-to-refresh control in the list to refresh products from the backend
- on tap opens a product details page with fullscreen zoomable image
- allows to add a custom note for a product
## Which architectures/technologies/frameworks are used?
- MVVM + Coordinators
- Protocol Oriented Programming
- CoreData
- Unit and UI tests
- Cocoapods
- Mockaroo - backend API mocking tool
