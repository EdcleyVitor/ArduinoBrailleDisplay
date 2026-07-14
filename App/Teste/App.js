import React, { useState, useEffect } from 'react';
import { StyleSheet, Text, View, Button, FlatList, TouchableOpacity, PermissionsAndroid, Platform } from 'react-native';
import { BleManager } from 'react-native-ble-plx';

const manager = new BleManager();

export default function App() {
  const [bluetoothState, setBluetoothState] = useState('Desconhecido');
  const [devices, setDevices] = useState([]);
  const [scanning, setScanning] = useState(false);

  useEffect(() => {
    const subscription = manager.onStateChange((state) => {
      if (state === 'PoweredOn') {
        setBluetoothState('LIGADO 🟢');
      } else {
        setBluetoothState('DESLIGADO 🔴');
      }
    }, true);
    return () => subscription.remove();
  }, []);

  const requestPermissions = async () => {
    if (Platform.OS === 'android' && Platform.Version >= 23) {
      const granted = await PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
      ]);
      return (
        granted['android.permission.ACCESS_FINE_LOCATION'] === 'granted' &&
        granted['android.permission.BLUETOOTH_SCAN'] === 'granted' &&
        granted['android.permission.BLUETOOTH_CONNECT'] === 'granted'
      );
    }
    return true;
  };

  const startScan = async () => {
    const hasPermission = await requestPermissions();
    if (!hasPermission) return;

    setDevices([]);
    setScanning(true);
    manager.startDeviceScan(null, null, (error, device) => {
      if (error) {
        setScanning(false);
        return;
      }
      if (device && device.name) {
        setDevices((prev) => {
          if (prev.some((d) => d.id === device.id)) return prev;
          return [...prev, { id: device.id, name: device.name }];
        });
      }
    });

    setTimeout(() => {
      manager.stopDeviceScan();
      setScanning(false);
    }, 10000);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🛜 Braille Bridge App</Text>
      <Text style={styles.status}>Bluetooth: {bluetoothState}</Text>
      
      <Button 
        title={scanning ? "Buscando..." : "Buscar Aparelhos Bluetooth"} 
        onPress={startScan} 
        disabled={scanning}
      />

      <FlatList
        data={devices}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity style={styles.deviceItem}>
            <Text style={styles.deviceName}>{item.name}</Text>
            <Text style={styles.deviceId}>{item.id}</Text>
          </TouchableOpacity>
        )}
        style={styles.list}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, backgroundColor: '#f7fafc', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: 'bold', marginBottom: 16, textAlign: 'center', color: '#1a365d' },
  status: { fontSize: 16, marginBottom: 20, textAlign: 'center', fontWeight: '600' },
  list: { marginTop: 20 },
  deviceItem: { padding: 12, backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#e2e8f0', borderRadius: 8, marginBottom: 8 },
  deviceName: { fontSize: 16, fontWeight: 'bold', color: '#2d3748' },
  deviceId: { fontSize: 12, color: '#718096' }
});
