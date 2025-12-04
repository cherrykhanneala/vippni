# VIPNNI Seller Portal

A fully functional Next.js application for the VIPNNI Seller Platform. This application allows vendors to manage their products, orders, and earnings.

## Features

- **Authentication**: Email/Password and Google Sign-in
- **Dashboard**: Overview of shop statistics and quick actions
- **Products Management**: Upload, edit, and delete products
- **Orders Management**: View and track orders by status (Pending, On the Way, Completed)
- **Notifications**: Real-time notifications from Firebase
- **Profile Management**: View and edit vendor information

## Tech Stack

- **Framework**: Next.js 16 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: React Context API

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

1. Navigate to the Next.js app directory:
   ```bash
   cd nextjs-app
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env.local` file with your Firebase configuration (optional - defaults are provided):
   ```env
   NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_storage_bucket
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
   NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=your_measurement_id
   ```

4. Run the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build for Production

```bash
npm run build
npm start
```

## Project Structure

```
nextjs-app/
├── app/                    # Next.js App Router pages
│   ├── dashboard/         # Dashboard/home page
│   ├── forgot-password/   # Password reset page
│   ├── login/             # Login page
│   ├── notifications/     # Notifications page
│   ├── orders/            # Orders management
│   ├── products/          # Products management
│   │   ├── [id]/          # Product detail/edit page
│   │   └── upload/        # Product upload page
│   ├── profile/           # Profile page
│   └── signup/            # Sign up page
├── components/            # Reusable React components
├── contexts/              # React Context providers
├── hooks/                 # Custom React hooks
└── lib/                   # Utility functions and Firebase config
```

## Color Scheme

The app uses the following color palette (matching the original Flutter app):

- **Primary**: #31135F (Dark Purple)
- **Secondary**: #6B29D1 (Purple)
- **Accent**: #FFB23D (Orange/Gold)
- **Highlight**: #4ABDFF (Light Blue)
- **Light Background**: #D6F7FA (Light Cyan)

## Firebase Setup

The app is configured to use the existing VIPNNI Firebase project. The Firestore database should have the following collections:

- `vendors`: Vendor/seller information
- `products`: Product listings
- `orders`: Customer orders
- `vendors/{vendorId}/notifications`: Vendor notifications

## License

This project is private and not intended for redistribution.
