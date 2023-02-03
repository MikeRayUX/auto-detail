module Api::V1::Washers::IntroSlides
  extend ActiveSupport::Concern
    INTRO_SLIDES = [
      {
        main_heading: "Welcome to the Washer Beta!",
        content_blocks: [
          {
            block_heading: '',
            block_content: 'With the FreshAndTumble.com Washer app, you can earn money from home using your home Washer, Dryer and Laundry Space to Wash and Fold FreshAndTumble Customer Laundry Orders while working on your own schedule!',
            notices: [
              {
                heading: 'Disclaimer',
                content: 'The Washer Program and this App are currently in Beta. Functionality will change over time with features being added/removed in the future.'
              }
            ]
          }
        ]
      },
      {
        main_heading: 'How It Works',
        content_blocks: [
          {
            block_heading: '1. Accept a Wash Offer',
            block_content: 'Tap to accept a wash offer (distance is based on your primary address that you signed up with)',
            notices: []
          },
          {
            block_heading: '2. Pickup',
            block_content: "Once you've accepted a wash offer, you will be prompted to travel to the customer's address and scan the customer bags to complete a pickup. Once an order has been picked up, you have 24 hours to return the completed order.",
            notices: []
          },
          {
            block_heading: '3. Wash',
            block_content: "Once the order has been picked up, you will see the customer's requested wash instructions including detergent, softener and optional special instructions.",
            notices: []
          },
          {
            block_heading: '4. Delivery (Get Paid)',
            block_content: "Once the order has been delivered, you will recieve an automatic deposit to the bank account you registered your Washer account with (48-72 hours after order completion)",
            notices: []
          },
        ]
      }
    ]
end