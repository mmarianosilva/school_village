import React from 'react';
import { StyleSheet, Text, View, TextInput } from 'react-native';

export default class Splash extends React.Component {

  constructor(props) {
    super(props);
  }


  render() {
    const { navigate } = this.props.navigation;
    setTimeout(() => {
      navigate('Login', { name: 'Login' });
    }, 2000);

    return (
      <View style={styles.splash}>
        <Text style={styles.splashText}>School Village</Text>
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
    fontSize: 32
  }
});
