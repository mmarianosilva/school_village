import React from 'react';
import { StyleSheet, Text, View, Button, TextInput, Alert } from 'react-native';

export default class Login extends React.Component {

  static navigationOptions = {
    title: 'Log In',
  };

  render() {
    const { navigate } = this.props.navigation;

    return (
      <View style={styles.splash}>
        <TextInput
            style={{height: 40, width: 300, borderColor: 'gray', borderWidth: 1, margin: 12}}
            placeholder='Email'
        />
        <TextInput
            style={{height: 40, width: 300, borderColor: 'gray', borderWidth: 1, margin: 12}}
            placeholder='Password'
        />
        <Button style={styles.splashText} title='Login' onPress={() => {
            navigate('Dashboard', { name: 'Dashboard' });
        }}/>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  splash: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center'
  },
  splashText: {
    fontSize: 32,
    width: 300,
    padding: 8
  }
});
