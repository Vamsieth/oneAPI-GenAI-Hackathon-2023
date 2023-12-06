const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const VoiceResponse = require('twilio').twiml.VoiceResponse;
const { Sequelize } = require("sequelize");
const app = express();

const openAI = require('openai');

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json()); // Parse JSON bodies
app.use(cors());
// Create PostgreSQL connection pool


const port = process.env.PORT || 3000;
app.use(express.json());

const sequelize = new Sequelize('postgres://root:WDGvRSZ2krtrJZdMc8GIUjm9UV1wPOP1@dpg-cll4b0cjtl8s73f7f13g-a.oregon-postgres.render.com/calllist', {

  dialect: "postgres",
  logging: false,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false,
    },
  },
});

sequelize
  .sync()
  .then(() => {
    console.log("Database connected");
  })
  .catch((err) => {
    console.log(err);
    console.log("Unable to connect to database");
  });


// Function to handle Twilio call
function handleTwilioCall(req, res) {
  const twiml = new VoiceResponse();

  twiml.say('Welcome to our customer care. Please provide your name, orderId, and the issue you are facing.');

  // Handle user input using Gather
  twiml.gather({
    input: 'speech',
    timeout: 3,
    action: '/handle-response',
    method: 'POST',
  });

  res.type('text/xml');
  res.send(twiml.toString());
}

// Function to handle JSON data
function handleJsonData(req, res) {
  const isTwilioRequest = req.body && req.body.SpeechResult !== undefined; // Check if it's a Twilio request


  if (isTwilioRequest) {
    // Handle Twilio request
    const { SpeechResult } =  req.body.SpeechResult;
    const name = SpeechResult;
  
    const orderId = '12345'; // Extract orderId from user input
    const issue = 'Delivery Issue'; // Extract issue from user input

    // Perform NLP and ML analysis here to determine priority

    // Simulate urgency check
    let isUrgent = true; // Replace with your urgency determination logic


const openai = new openAI({
  apiKey: "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",
});

async function checkPriority() {
  const prompt = `Given the following user input: ${name}, determine the priority level of the customer service issue. The user may mention their name, order ID, and describe the issue they are facing.

  Consider the following priority criteria:
  - If the item received is defective, broken, damaged, or if the user received the wrong item, it's considered 'high' priority.
  - If the issue is related to the quality of the product not meeting expectations, it's considered 'medium' priority.
  - For other issues, you can default to 'low' priority.
  
  Examples of user inputs:
  1. "Hi, my name is [Name], and my order ID is [Order ID]. The item I received is defective, and..."
  2. "I received order [Order ID], but the product is broken and..."
  3. "This is [Name]. I ordered [Product], and the quality is not as expected. There's an issue with..."
  
  Please generate a response indicating the priority level of the customer service issue based on the user input, considering the provided priority criteria. If the user input doesn't align with these criteria, you can mention that the priority is high`;
  
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      
        messages: [
    {
      "role": "user",
      "content":prompt
    }
      ],
      temperature: 1,
      max_tokens: 50,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    });
    
    const priorityLevel = response.choices[0].message.content;
    console.log(priorityLevel);
    return priorityLevel;
  } catch (error) {
    console.error("Error:", error.message);
    throw error;
  }
}

async function priority() {
  try {
    const p = await checkPriority();

    if (p.includes('high')) {
      isUrgent = true;
    } else if (p.includes('medium')) {
      isUrgent = false;
    } else {
      isUrgent = false;
    }

    // Continue with the rest of your code...
    console.log(isUrgent);

  } catch (error) {
    console.error("Error:", error.message);
  }
}

priority();

    if (isUrgent) {
      // Insert data into PostgreSQL
      const CustomerCare = sequelize.define('customer_care', {
        name: Sequelize.STRING,
        order_id: Sequelize.STRING,
        issue: Sequelize.STRING,
      });
      CustomerCare.sync()
        .then(() => {
          console.log('CustomerCare table created (if not existed)');
        })
        .catch((error) => {
          console.error('Error creating CustomerCare table:', error);
        });
      CustomerCare.create({ name, order_id: orderId, issue })
        .then((result) => {
          console.log('Data inserted into PostgreSQL');
          res.status(200).json({ message: 'Data inserted successfully' });
        })
        .catch((err) => {
          console.error('Error inserting data into PostgreSQL: ', err);
          res.status(500).json({ error: 'Internal Server Error' });
        });

    } else {
      res.status(200).json({ message: 'Data processed successfully' });
    }
  } else {
    // Handle direct JSON input
    const { name, orderId, issue } = req.body;

    // Insert data into PostgreSQL
    const CustomerCare = sequelize.define('customer_care', {
      name: Sequelize.STRING,
      order_id: Sequelize.STRING,
      issue: Sequelize.STRING,
    });
    CustomerCare.sync()
      .then(() => {
        console.log('CustomerCare table created (if not existed)');
      })
      .catch((error) => {
        console.error('Error creating CustomerCare table:', error);
      });
    CustomerCare.create({ name, order_id: orderId, issue })
      .then((result) => {
        console.log('Data inserted into PostgreSQL');
        res.status(200).json({ message: 'Data inserted successfully' });
      })
      .catch((err) => {
        console.error('Error inserting data into PostgreSQL: ', err);
        res.status(500).json({ error: 'Internal Server Error' });
      });
  }
}
function getAllData(req, res) {
  const CustomerCare = sequelize.define('customer_care', {
    name: Sequelize.STRING,
    order_id: Sequelize.STRING,
    issue: Sequelize.STRING,
  });

  CustomerCare.findAll()
    .then((data) => {
      res.status(200).json(data);
    })
    .catch((err) => {
      console.error('Error retrieving data from PostgreSQL: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    });
}

app.post('/voice', handleTwilioCall);
app.post('/handle-response', handleJsonData);
app.get('/get-all-data', getAllData);



app.listen(3000, '0.0.0.0', () => {
  console.log('Server is running on port 3000');
});
