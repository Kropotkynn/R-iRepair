import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "R iRepair - Réparation Matériel Informatique",
  description: "Service professionnel de réparation de smartphones, ordinateurs, tablettes et consoles. Réparation rapide et de qualité.",
  keywords: "réparation, smartphone, iPhone, Samsung, ordinateur, laptop, tablette, console, réparation écran, batterie",
  authors: [{ name: "R iRepair" }],
  creator: "R iRepair",
  publisher: "R iRepair",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
};

export const viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr" className="scroll-smooth">
      <body className={`${inter.className} antialiased min-h-screen bg-background`}>
        <div className="flex flex-col min-h-screen">
          {children}
        </div>
      </body>
    </html>
  );
}