module Api::V1::Washers::EligibilityQuestions
  extend ActiveSupport::Concern

  ELIGIBILITY_QUESTIONS = [
      {
        id: 1,
        answer: false,
        question: 'Do you currently live in the City Area selected above?'
      },
      {
        id: 2,
        answer: false,
        question: 'Are you 21 or older and legally able to work in the United States of America?'
      },
      {
        id: 3,
        answer: false,
        question: 'Do you have a valid Drivers License and Car Insurance for the vehible that you will be using to perform pickups and deliveries?'
      },
      {
        id: 4,
        answer: false,
        question: 'Do you have a valid Social Security Number? (SSN)'
      },
      {
        id: 5,
        answer: false,
        question: 'Do you have reliable and adequate transportation to pickup and deliver laundry orders?'
      },
      {
        id: 6,
        answer: false,
        question: 'Are you able to safely up to 30 pounds (lbs) from a standing position?'
      },
    ]
end