import { StyleSheet } from 'react-native'; 

export const Colors = { 
  nexusBlue: '#1D4ED8', 
  cosmicPurple: '#6D28D9', 
  neutralLight: '#F9FAFB', 
  neutralDark: '#111827', 
}; 

export const GlobalStyles = StyleSheet.create({ 
  container: { flex: 1, backgroundColor: Colors.neutralLight, padding: 16 }, 
  textPrimary: { color: Colors.nexusBlue, fontWeight: 'bold', fontSize: 18 }, 
  textSecondary: { color: Colors.cosmicPurple, fontSize: 16, fontWeight: '600' }, 
  buttonPrimary: { backgroundColor: Colors.nexusBlue, padding: 12, borderRadius: 8 }, 
  buttonPrimaryText: { color: '#fff', fontWeight: 'bold' }, 
  logo: { width: 180, height: 60, resizeMode: 'contain', alignSelf: 'center', marginVertical: 20 }, 
}); 

/* ---- Dark Mode Support ---- */ 
export const DarkModeStyles = StyleSheet.create({ 
  container: { flex: 1, backgroundColor: Colors.neutralDark, padding: 16 }, 
  textPrimary: { color: Colors.cosmicPurple, fontWeight: 'bold', fontSize: 18 }, 
  textSecondary: { color: Colors.nexusBlue, fontSize: 16, fontWeight: '600' }, 
  buttonPrimary: { backgroundColor: Colors.cosmicPurple, padding: 12, borderRadius: 8 }, 
  buttonPrimaryText: { color: '#fff', fontWeight: 'bold' }, 
}); 
